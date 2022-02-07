/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


--Arial View of the whole data(covid_deaths)
select *
from Coviddata_exploration..covid_deaths
where continent is not null;

-- Countries with their location, date, total_cases, new_cases, total_deaths, population

Select Distinct location, date, total_cases, new_cases, total_deaths, population
From Coviddata_exploration..covid_deaths
where continent is not null
Order by Location Asc;

--Total Cases VS Total Deaths

Select Distinct location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From Coviddata_exploration..covid_deaths
where continent is not null
Order by Location Asc;
 
-- India's data 
--Likelyhood of dying in India if you contract covid
Select Distinct location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
From Coviddata_exploration..covid_deaths
Where location like '%India%'
Order by Location Asc;

--Totalcases Vs Population
--what percentage of population got covid in India?
Select Distinct location, date, population, total_cases,  (total_cases/population)*100 AS PercentagePopulationInfected
From Coviddata_exploration..covid_deaths
Where location like '%India%'
Order by 1,2;

--Country with highest infection rate
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
From Coviddata_exploration..covid_deaths
where continent is not null
Group by location, population 
Order by PercentagePopulationInfected DESC;

--	Countries with highest Deathcount
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Coviddata_exploration..covid_deaths
where continent is not null
group by location
Order by TotalDeathCount DESC;

--Breaking thing down by continents
--deathcount
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From Coviddata_exploration..covid_deaths
where continent is not null
group by continent
Order by TotalDeathCount DESC;

--deathpercentage(globally)

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Coviddata_exploration..covid_deaths
where continent is not null
Order by 1,2;

--lets add vaccinations into picture

select *
from Coviddata_exploration..covid_vaccinations;

--Total population Vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from Coviddata_exploration..covid_deaths dea
join Coviddata_exploration..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (Continent, location, date, population, New_vacccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from Coviddata_exploration..covid_deaths dea
join Coviddata_exploration..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp table
Drop table if exists #PercentPopulationVaccinated
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
, Sum(CONVERT( bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from Coviddata_exploration..covid_deaths dea
join Coviddata_exploration..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 

-- Creating View to store data for visualization
Create View Percent_P_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( bigint, vac.new_vaccinations)) Over (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from Coviddata_exploration..covid_deaths dea
join Coviddata_exploration..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3






