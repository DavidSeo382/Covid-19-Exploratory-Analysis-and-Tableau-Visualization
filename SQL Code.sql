-- Covid-19 Data Exploration

-- Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


select
	*
from 
	PortfolioProject..CovidDeaths
where
	continent is not null
order by
	3,4


-- Select Data that we are going to be using
select
	Location, date, total_cases, new_cases, total_deaths, population
from 
	PortfolioProject..CovidDeaths
where
	continent is not null
order by
	1,2


-- Total cases vs total deaths
-- Show likelihood of dying if you contract covid in the united states
select
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from 
	PortfolioProject..CovidDeaths
where
	Location like '%United States%' and
	continent is not null
order by
	1,2


-- Total cases vs population
-- Shows percentage of infected population in the United States
Select 
	Location, date, Population, total_cases, 
	(total_cases/population)*100 as PercentPopulationInfected
From 
	PortfolioProject..CovidDeaths
Where 
	location like '%United States%'
order by 1,2


-- Countries with highest infection rate compared to population
select
	Location, max(total_cases) as HighestInfenctionCount, Population, 
	max((total_cases/Population))*100 as PercentPopulationInfected
from 
	PortfolioProject..CovidDeaths
group by
	Location, Population
order by
	PercentPopulationInfected desc


-- Countries with highest death count per population
select
	Location, max(cast(Total_deaths as int)) as TotalDeathCount
from 
	PortfolioProject..CovidDeaths
where
	continent is not null
group by
	Location
order by
	TotalDeathCount desc


--Continents with the highest death count per population
select
	Location, max(cast(Total_deaths as int)) as TotalDeathCount
from 
	PortfolioProject..CovidDeaths
where
	continent is null
group by
	Location
order by
	TotalDeathCount desc


--Global Numbers
Select 
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From 
	PortfolioProject..CovidDeaths
where 
	continent is not null 
order by 
	1,2


--Total population vs Vaccinations
--Shows percentage of population that has recieved at least one covid vaccine
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as TotalRollingPeopleVaccinated
from
	PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where
	dea.continent is not null
order by
	2,3


--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalRollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as TotalRollingPeopleVaccinated
from
	PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date


--Query the temp table
Select 
	*, (TotalRollingPeopleVaccinated/Population)*100
From 
	#PercentPopulationVaccinated


--Create view 
create view PercentPopulationVaccinated as
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
	dea.date) as TotalRollingPeopleVaccinated
from
	PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where
	dea.continent is not null



-- Queries to be used for Tableau Dashboard

--Query #1 for Global Numbers
Select 
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From 
	PortfolioProject..CovidDeaths
where 
	continent is not null 
order by 
	1,2

--Query #2 for Continents with the highest death count per population 
--(Take out following locations in order to be consistent with above query)
select
	Location, max(cast(Total_deaths as int)) as TotalDeathCount
from 
	PortfolioProject..CovidDeaths
where
	continent is null
	and location not in ('World', 'European Union', 'International')
group by
	Location
order by
	TotalDeathCount desc


--Query #3 for Countries with highest infection rate compared to population
select
	Location, max(total_cases) as HighestInfenctionCount, Population, 
	max((total_cases/Population))*100 as PercentPopulationInfected
from 
	PortfolioProject..CovidDeaths
group by
	Location, Population
order by
	PercentPopulationInfected desc


--Query #4 Same as above except I added date to select and group by clauses
Select 
	Location, MAX(total_cases) as HighestInfectionCount, Population, date, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From 
	PortfolioProject..CovidDeaths
Group by 
	Location, Population, date
order by 
	PercentPopulationInfected desc
