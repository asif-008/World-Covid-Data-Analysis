-- Exploring Covid-19 data
--skills learned and used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



Select *
from PortfolioProject01.dbo.Covid_deaths
--Where continent is not null
order by 3,4




Select location, date, new_cases, total_cases, total_deaths, population
from PortfolioProject01.dbo.Covid_deaths
order by 1,2



--total cases vs total deaths


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject01.dbo.Covid_deaths
where location like '%ingdom%'
order by 1,2


-- total cases vs population

Select location, date, population, total_cases,  (total_cases/population)*100 as covid_rate
from PortfolioProject01.dbo.Covid_deaths
order by 1,2


-- Countries with highest infection rate

Select location, population, max(total_cases) as highest_count,  max(total_cases/population)*100 as covid_rate
from PortfolioProject01.dbo.Covid_deaths
group by location, population
order by covid_rate desc



-- Looking at countries with highest deaths


Select location, max(cast(total_deaths as int)) as death_count
from PortfolioProject01.dbo.Covid_deaths
Where continent is not null
group by location
order by death_count desc



-- global number
Select location, sum(cast(new_deaths as bigint)) as death_count, sum(new_cases) as totalcase
from PortfolioProject01.dbo.Covid_deaths
Where continent is null
group by location
order by death_count desc



--looking at total population vs vaccinations
select location,max(population) as Population, max(cast(total_vaccinations as bigint)) as Vaccine_given,
max(cast(people_fully_vaccinated as bigint)) as People_vaccinated, ((max(cast(people_fully_vaccinated as bigint)))*100/population) as Vaccinated_percentage
from  PortfolioProject01.dbo.Covid_vaccinations 
where continent is not null
group by location, population
order by 1



select *
from PortfolioProject01.dbo.Covid_deaths dea
Join PortfolioProject01.dbo.Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- USE CTE


--looking at total population vs vaccinations
select continent, location, date, new_vaccinations, sum(convert(bigint, new_vaccinations)) over (partition by location order by date) as RollingPeopleVaccinated
from  PortfolioProject01.dbo.Covid_vaccinations 
where continent is not null

order by 1,2




With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject01..Covid_deaths dea
Join PortfolioProject01..Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject01..Covid_deaths dea
Join PortfolioProject01..Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingVaccinationPercentage
From #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject01..Covid_deaths dea
Join PortfolioProject01..Covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Create View CovidDeathStats as
Select location, max(cast(total_deaths as int)) as death_count
from PortfolioProject01.dbo.Covid_deaths
Where continent is not null
group by location




--looking at total population vs vaccinations
Create View Vaccine_stat as
select location,max(population) as Population, max(cast(total_vaccinations as bigint)) as Vaccine_given,
max(cast(people_fully_vaccinated as bigint)) as People_vaccinated, ((max(cast(people_fully_vaccinated as bigint)))*100/population) as Vaccinated_percentage
from  PortfolioProject01.dbo.Covid_vaccinations 
where continent is not null
group by location, population











--QUERIES FOR TABLEAU VISUALIZATIONS


--1


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject01..Covid_deaths
where continent is not null 
order by 1,2

--2

Select location,  max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject01..Covid_Deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


--3

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject01..Covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject01..Covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc


