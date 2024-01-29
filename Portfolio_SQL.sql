
/*Visualizing The Tables */

select *
from PortfolioProject..Covid_Death
order by 3,4

select *
from PortfolioProject..Covid_Vaccines
order by 3,4

select location,date, population,  total_cases, new_cases, total_deaths
from PortfolioProject..Covid_Death
order by 1,2





/* As Time passes, visualizing Death Percentage in every different loacation */ 

SELECT location,date,population,(CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS Death_Percentage
FROM PortfolioProject..Covid_Death
WHERE location like '%desh%'
ORDER BY  1, 2;


/* Looking at Total Case VS Total Deaths*/

SELECT location,date,total_cases,total_deaths,(CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS Death_Percentage
FROM PortfolioProject..Covid_Death
WHERE location like '%desh%'
ORDER BY  1, 2;



/* Looking at Country-wise Population VS Total Deaths*/
SELECT location,Max(population) as Total_Population, Max(Cast(total_deaths as float)) as Total_Death_Count 
FROM PortfolioProject..Covid_Death
--WHERE location like '%desh%'
where continent is not null
group by location
order by  Total_Death_Count DESC



/* Looking at Continent-wise Total Deaths*/
SELECT location, Max(Cast(total_deaths as float)) as Total_Death_Count 
FROM PortfolioProject..Covid_Death
--WHERE location like '%desh%'
where continent is null AND location NOT LIKE '%income%' 
group by location
order by  Total_Death_Count DESC



--/* Looking at Income-wise Total Deaths*/
SELECT location, Max(Cast(total_deaths as float)) as Total_Death_Count 
FROM PortfolioProject..Covid_Death
--WHERE location like '%desh%'
where continent is null AND location  LIKE '%income%' 
group by location
order by  Total_Death_Count DESC



/* the growth rate of new cases and deaths over time for different continents or countries*/
SELECT
    continent,location,date,new_cases, new_deaths, population, total_cases, total_deaths, 
	(new_cases / population) * 1000000 AS new_cases_per_million, (new_deaths / population) * 1000000 AS new_deaths_per_million
FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS NOT NULL
    AND location IS NOT NULL
ORDER BY 2,3



/* Death Percentage of total population of countries in descending order*/
SELECT
    location, continent,
	Max(Cast(population as float)) as Total_Population,
	Max(Cast(total_cases as float)) as Total_case_Count,
	Max(Cast(total_deaths as float)) as Total_Death_Count,
	Max(Cast(total_deaths as float))/Max(Cast(population as float))*100 as Death_percentage,
	Max(Cast(total_cases as float))/Max(Cast(population as float))*100 as Infected_percentage


FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS not NULL
group by continent,location
ORDER BY Death_percentage DESC

/* Death Percentage of total population of continents in descending order*/

SELECT
    location,
	Max(Cast(population as float)) as Total_Population,
	Max(Cast(total_cases as float)) as Total_case_Count,
	Max(Cast(total_deaths as float)) as Total_Death_Count,
	Max(Cast(total_deaths as float))/Max(Cast(population as float))*100 as Death_percentage,
	Max(Cast(total_cases as float))/Max(Cast(population as float))*100 as Infected_percentage


FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS  NULL and location not like '%income%' and location not like '%union%'
group by continent,location
ORDER BY Death_percentage DESC


/* Metrics per million*/

SELECT
    location,
    MAX(CAST(population AS float)) as Total_Population,
    MAX(CAST(total_cases AS float)) as Total_Case_Count,
    MAX(CAST(total_deaths AS float)) as Total_Death_Count,
    MAX(CAST(total_cases AS float)) / MAX(CAST(population AS float)) * 1000000 AS Total_Cases_Per_Million,
    MAX(CAST(total_deaths AS float)) / MAX(CAST(population AS float)) * 1000000 AS Total_Deaths_Per_Million
 
FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS NOT NULL
GROUP BY
    location 
ORDER BY
    Total_Deaths_Per_Million desc

/* Healthcare system impact analysis*/

SELECT
    location,
    MAX(CAST(icu_patients AS float)) as Max_ICU_Patients,
    MAX(CAST(icu_patients_per_million AS float)) as Max_ICU_Patients_Per_Million,
    MAX(CAST(hosp_patients AS float)) as Max_Hospital_Patients,
    MAX(CAST(hosp_patients_per_million AS float)) as Max_Hospital_Patients_Per_Million
    
FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS not NULL and icu_patients is not null and hosp_patients is not null
GROUP BY
    location 
ORDER BY
    location;


/*Analyzing the reproduction rate over time or virus waves.The reproduction rate measures how many people, on average, a single infected person will transmit the virus to. */
SELECT
    location,
    date,
    MAX(CAST(reproduction_rate AS float)) as Max_Reproduction_Rate
FROM
    PortfolioProject..Covid_Death
WHERE
    continent IS NOT NULL and location like '%states%'
GROUP BY
    location, date
ORDER BY
     date



/* GLOBAL NUMBERS */

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..Covid_Death
--Where location like '%states%'
where continent is not null 
Group By date
order by 1,2





/* Total Population vs Vaccinations
   Shows Percentage of Population that has recieved at least one Covid Vaccine */

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Death dea
Join PortfolioProject..Covid_Vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


/* Using CTE to perform Calculation on Partition By in previous query */

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Death dea
Join PortfolioProject..Covid_Vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
from PopvsVac
order by PercentPopulationVaccinated desc





/* Using Temp Table to perform Calculation on Partition By in previous query */
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Death dea
Join PortfolioProject..Covid_Vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *,(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated
order by 2,3



/*Creating Views*/

Create view  PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Death dea
Join PortfolioProject..Covid_Vaccines vac
	On dea.location = vac.location
	and dea.date = vac.date


