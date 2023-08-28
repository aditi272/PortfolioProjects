/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

use sql_tutorial;


SELECT location, new_date, total_cases, new_cases, total_deaths, population  FROM  covid_deaths 
order by 1,2;
 
 -- shows likelihood of dying if you contract covid in your country
SELECT location, new_date, total_cases,  total_deaths, (total_deaths/total_cases)*100  FROM  covid_deaths 
where location = 'India'
order by 1,2;


-- Shows what percentage of population got Covid
SELECT location, new_date, total_cases,  total_deaths, population,  (total_cases/population)*100 FROM  covid_deaths 
where location = 'India'
order by 1,2;


-- looking at countries with highest infection rate compared to population 
SELECT location,  population, total_cases, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected FROM  covid_deaths 
GROUP BY location,population,total_cases
order by PercentPopulationInfected DESC ;

-- showing countries highest death count per population
SELECT
  location,
  MAX(total_deaths) AS HighestDeathCount
FROM
  covid_deaths
WHERE
continent IS NOT NULL
  AND continent <> ''
GROUP BY
  location
ORDER BY
  HighestDeathCount DESC;

 -- LET'S BREAK THINGS DOWN BY CONTINENT
 -- showing continents with the highest death count per population
 SELECT
  continent,
   CAST(MAX(total_deaths) AS unsigned ) AS HighestDeathCount
FROM
  covid_deaths
WHERE
continent IS NOT NULL
  AND continent <> ''
GROUP BY
  continent
ORDER BY
  HighestDeathCount DESC;


-- global numbers 
SELECT new_date, SUM(new_cases) as total_cases,  SUM(new_deaths) as total_deaths, (SUM(new_deaths )/SUM(new_cases))*100  FROM  covid_deaths 
where continent is not null AND continent <> ''
group by new_date
order by 1,2;

SELECT  SUM(new_cases) as total_cases,  SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100  FROM  covid_deaths 
where continent is not null AND continent <> ''
-- group by new_date
order by 1,2;


-- looking at total population vs vaccination
SELECT dea.continent , dea.location,dea.new_date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location order by dea.location , dea.new_date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccination as vac ON dea.location = vac.location and dea.new_date = vac.new_date
where dea.continent is not null AND dea.continent <> ''
order by 2,3;

-- use cte

WITH
 Popvsvac  (Continent, Location, Date, Population,NewVaccination, RollingPeopleVaccinated)
  AS
(SELECT dea.continent , dea.location,dea.new_date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location order by dea.location , dea.new_date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccination as vac ON dea.location = vac.location and dea.new_date = vac.new_date
where dea.continent is not null AND dea.continent <> ''
order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM Popvsvac;

-- temp table
DROP TABLE if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent varchar(255), 
Location varchar(255), 
Date date, 
Population numeric ,
NewVaccination numeric, 
RollingPeopleVaccinated numeric);
Insert into PercentPopulationVaccinated
SELECT dea.continent , dea.location,dea.new_date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location order by dea.location , dea.new_date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccination as vac ON dea.location = vac.location and dea.new_date = vac.new_date;
-- where dea.continent is not null AND dea.continent <> ''
-- order by 2,3;

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

-- create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent , dea.location,dea.new_date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (partition by dea.location order by dea.location , dea.new_date) as RollingPeopleVaccinated
FROM covid_deaths as dea
JOIN covid_vaccination as vac ON dea.location = vac.location and dea.new_date = vac.new_date
where dea.continent is not null AND dea.continent <> ''
order by 2,3;

SELECT * FROM PercentPopulationVaccinated;

