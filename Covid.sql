USE covid

SELECT *
FROM dbo.vaccination
ORDER BY date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.deaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths
FROM dbo.deaths
--WHERE continent IS NOT NULL
WHERE location like 'World'
ORDER BY 1,2


-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases * 1.0/population * 1.0) * 100 AS cases_percentage
FROM dbo.deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Countries with Highest Infection Rate (IR) compared to population

 

-- Countries with Highest Death Rate 

SELECT location,  MAX(total_deaths) as total_deaths
FROM dbo.deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Death and infection numbers 

SELECT  date, 
		SUM(new_cases) as cases, 
		SUM(new_deaths) as deaths, 
		(SUM(new_deaths * 1.0)/SUM(new_cases * 1.0)*100) AS death_percentage

FROM dbo.deaths
WHERE continent IS NOT NULL
      AND new_cases NOT LIKE 0
GROUP BY date
ORDER BY 1,2


-- Deaths per continent

SELECT location,  MAX(total_deaths) as total_deaths
FROM dbo.deaths
WHERE continent IS NULL
	AND location NOT LIKE 'World'
	AND location NOT LIKE '%income'
	AND location NOT LIKE '%Union'
GROUP BY location
ORDER BY 2 DESC

-- Total population vs vaccination
-- CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, vaccinations_cumulative)
AS
(
SELECT dea.continent, 
	   dea.location, 
	   dea.date, population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinations_cumulative
--	   

FROM covid.dbo.deaths dea
JOIN covid.dbo.vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, ((vaccinations_cumulative*1.0)/CAST(population AS bigint))*100
FROM PopvsVac


-- Total population vs vaccination
-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinations_cumulative numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, 
	   dea.location, 
	   dea.date, population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinations_cumulative
--	   

FROM covid.dbo.deaths dea
JOIN covid.dbo.vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, ((vaccinations_cumulative*1.0)/CAST(population AS bigint))*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	   dea.location, 
	   dea.date, population, 
	   vac.new_vaccinations, 
	   SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as vaccinations_cumulative

FROM covid.dbo.deaths dea
JOIN covid.dbo.vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL