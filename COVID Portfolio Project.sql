SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

-- Selecting the data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Nigeria'
ORDER BY 1,2

SELECT continent, SUM(total_cases) AS TotalCase, SUM(CAST(total_deaths as INT)) AS TotalDeaths, 
	   SUM(CAST (total_deaths AS  INT))/SUM(total_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_percentage

-- Total Cases Vs Population
-- Shows what percentage of the population go Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Nigeria'
ORDER BY 1,2

-- Countries with Highest infection Rate Compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Countries with the Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Where continent is NULL
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Breakdown
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Total Vaccination

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$  death
JOIN PortfolioProject..CovidVaccinations$   vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- USING A CTE
WITH PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollongPeopleVaccination)
AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$  death
JOIN PortfolioProject..CovidVaccinations$   vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollongPeopleVaccination/Population)*100
FROM PopvsVacc





-- TEMP TABLES

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$  death
JOIN PortfolioProject..CovidVaccinations$   vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollIngPeopleVaccination/Population)*100
FROM #PercentPopulationVaccinated

--Creating View for Data Visualization

CREATE VIEW PercentPopulationVaccination AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER by death.location, death.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$  death
JOIN PortfolioProject..CovidVaccinations$   vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccination