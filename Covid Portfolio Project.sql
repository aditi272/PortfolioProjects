CREATE DATABASE sql_tutorial;
CREATE TABLE sql_tutorial.covid_vaccination(
iso_code varchar(5),
continent varchar(20),
location varchar(50),
date varchar(10),
new_tests int,
total_tests int,
total_tests_per_thousand double,
new_tests_per_thousand double,
new_tests_smoothed double,
new_tests_smoothed_per_thousand double,
positive_rate double,
tests_per_case double,
tests_units varchar(50),
total_vaccinations int,
people_vaccinated int,
people_fully_vaccinated int,
new_vaccinations int,
new_vaccinations_smoothed  int,
total_vaccinations_per_hundred double,
people_vaccinated_per_hundred  double,
people_fully_vaccinated_per_hundred double,
new_vaccinations_smoothed_per_million double,
stringency_index double,
population_density double,
median_age double,
aged_65_older double,
aged_70_older double,
gdp_per_capita double,
extreme_poverty double,
cardiovasc_death_rate double,
diabetes_prevalence double,
female_smokers double,
male_smokers double,
handwashing_facilities double,
hospital_beds_per_thousand double,
life_expectancy double,
human_development_index double

)

;

-- LOAD DATA LOCAL INFILE 'Covid Vacinations.csv' INTO TABLE sql_tutorial.covid_vaccination
-- FIELDS TERMINATED BY ','
-- IGNORE 1 LINES;



-- CREATE TABLE sql_tutorial.covid_deaths(
-- iso_code varchar(5),
-- continent varchar(20),
-- location varchar(50),
-- date varchar(10),
-- population double,
-- total_cases int,
-- new_cases int,
-- new_cases_smoothed double,
-- total_deaths int,
-- new_deaths int,
-- new_deaths_smoothed double,
-- total_cases_per_million double,
-- new_cases_per_million double,
-- new_cases_smoothed_per_million double,
-- total_deaths_per_million double,
-- new_deaths_per_million double,
-- new_deaths_smoothed_per_million double,
-- reproduction_rate double,
-- icu_patients int,
-- icu_patients_per_million double,
-- hosp_patients int,
-- hosp_patients_per_million double,
-- weekly_icu_admissions double,
-- weekly_icu_admissions_per_million double,
-- weekly_hosp_admissions double,
-- weekly_hosp_admissions_per_million double);

-- LOAD DATA LOCAL INFILE 'Covid Vacinations.csv' INTO TABLE sql_tutorial.covid_deaths
-- FIELDS TERMINATED BY ','
-- IGNORE 1 LINES;
use sql_tutorial;
-- SELECT * FROM covid_vaccination;
SELECT * FROM covid_deaths
;

-- SELECT * FROM sql_tutorial.covid_deaths order by 3,4;

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

