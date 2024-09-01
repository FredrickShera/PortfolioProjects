SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
ORDER BY 3,4


-- select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT null
ORDER BY 1,2

-- Looking at the Total Cases vs Population
--Shows what percentage f population has covid

SELECT location, date, population, total_cases, (total_cases/population)* 100 AS PercentageofInfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%%'
AND continent IS NOT null
ORDER BY 1,2

--Looking at countries with highest infection rates compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)* 100 AS PercentageofInfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
GROUP BY Location, Population
ORDER BY PercentageofInfectedPopulation DESC

-- Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET US BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death counts

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Global or Universal Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

-- Not Grouping by date
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentages
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3


-- Uing CTE

WITH PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP Table

DROP Table IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store dat for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null

SELECT *
FROM PercentPopulationVaccinated