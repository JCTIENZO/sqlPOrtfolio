/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM sqlPortfolio..CovidDeaths
where continent is not null
ORDER BY 3,4
SELECT *
FROM sqlPortfolio..CovidVaccinations
where continent is not null
ORDER BY 3,4

-- total cases vs deaths per location
-- shows percentage in a location

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100  as Death_percentage 
FROM sqlPortfolio..CovidDeaths
where location  like '%philippines%' and continent is not null
ORDER BY 5 desc

-- Total Cases vs Population
-- show percentage of of population infected with covid

Select Location, date, total_cases, population,(total_cases/population) * 100  as infected_percentage
FROM sqlPortfolio..CovidDeaths
--where location  like '%philippines%' and continent is not null
where continent is not null
ORDER BY 5 desc

-- Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestCases, max((total_cases/population))*100 as PercentagePopulationInfected
FROM sqlPortfolio..CovidDeaths
--where location  like '%philippines%' and continent is not null
where continent is not null
group by location, population
ORDER BY PercentagePopulationInfected desc

-- showing countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as Highestdeaths, max((total_deaths/population))*100 as PercentagePopulationDeath
FROM sqlPortfolio..CovidDeaths
--where location  like '%philippines%' and continent is not null
where continent is not null
group by location
ORDER BY Highestdeaths desc

-- showing death counts per continent

Select continent, Max(cast(total_deaths as int)) as Total_deaths, max((total_deaths/population))*100 as PercentagePopulationDeath
FROM sqlPortfolio..CovidDeaths
where continent is not null
group by continent
ORDER BY 2 desc

-- GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from sqlPortfolio..CovidDeaths
where continent is not null
-- Group by date 
order by 1,2


-- total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM sqlPortfolio..CovidDeaths dea
join sqlPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte

with popvsvac (Continent, location, date, population, new_vaccinaitons, rollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM sqlPortfolio..CovidDeaths dea
join sqlPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
SELECT *, (rollingPeopleVaccinated/population)*100
from popvsvac

--temp table

Drop table if Exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM sqlPortfolio..CovidDeaths dea
join sqlPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (rollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


-- create view

Create View percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM sqlPortfolio..CovidDeaths dea
join sqlPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from percentPopulationVaccinated