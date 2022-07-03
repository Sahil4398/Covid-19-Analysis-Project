Select * from CovidProject..CovidDeaths Order By 3,4
--Select * from CovidProject..CovidVaccinations Order By 3,4

Select location, date, population, new_cases, total_cases, total_deaths
from CovidProject..CovidDeaths
Order By 1,2

-- Liklihood of dying due to covid in India (total_deaths/total_cases)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths 
where location like '%India%'
Order By 1,2

-- Liklihood of dying due to covid in each country (total_deaths/total_cases)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..CovidDeaths
Order By 1,2

-- Percentage of Population got covid in India (Total_cases/Population)
Select location, date, population, total_cases, (total_cases/population)*100 as Infected_Population_Percentage
from CovidProject..CovidDeaths 
where location like '%India%'
Order By 1,2

-- Maximum percentage of population infected group by countries
Select location, population, MAX(total_cases) as Highest_Infected_Count, MAX(total_cases/population)*100 as Infected_Population_Percentage 
from CovidProject..CovidDeaths
Group By Location, Population
Order By Infected_Population_Percentage desc

-- Maximum Deaths per countries
Select Location, MAX(Cast (total_deaths as int)) as Total_Deaths_ByCountries
from CovidProject..CovidDeaths
Where Continent is not null
Group By Location
Order By Total_Deaths_ByCountries desc

-- Maximum Deaths per continent
Select Location, MAX(Cast(total_deaths as int)) as Total_Deaths_ByContinent
from CovidProject..CovidDeaths
Where Continent is null
Group By Location
Order By Total_Deaths_ByContinent desc

-- Global Numbers
-- New cases and deaths grouped by the Date

Select date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths
from CovidProject..CovidDeaths
where Continent is not null
Group by date
Order By Date

-- Total Death perentage according to Date

Select date, SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage_Daily
from CovidProject..CovidDeaths
where Continent is not null
Group by date
Order By Date

-- Total Death Percentage of World

Select SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage_Daily
from CovidProject..CovidDeaths
where Continent is not null

-- JOIN Covid Deaths and Covid Vaccination tables

Select * From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On dea.location = vac.location and dea.date = vac.date

-- Vaccinations per day for every location

Select dea.Continent, dea.location, dea.date, vac.new_vaccinations From
CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location and dea.date = vac.date
where dea.Continent is not null
Order by 2,3

-- Rolling total Vaccination according to country and date (NOT WORKING)
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location and dea.date = vac.date
where dea.Continent is not null
Order by 2,3



-- Total Vaccinations grouped by countries

Select dea.location, MAX(Cast(total_vaccinations as int)) as Total_vaccinations
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location
where dea.Continent is not null
Group by dea.location
Order by Total_vaccinations desc

--Using CTE(Comon Table Expression) use this temporary table for performing DML on it loke select ,insert ,update or for a view

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location and dea.date = vac.date
where dea.Continent is not null
--Order by 2,3 (Canot use order by clause in here)
)
Select * from PopvsVac



with PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
Select dea.Continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location) as RollingVaccinationCount
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location and dea.date = vac.date
where dea.Continent is not null
--Order by 2,3 (Canot use order by clause in here)
)
Select * from PopvsVac

-- Using CTE for Location vs Vaccinations

with LocvsVac (Location, Total_Vaccinations)
as
(
Select dea.location, MAX(Cast(total_vaccinations as int)) as Total_vaccinations
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location
where dea.Continent is not null
Group by dea.location
--Order by Total_vaccinations desc
)
Select * from LocvsVac 
Order by Total_Vaccinations desc

-- Percent of Population vaccinated

with LocvsVacvsPer (Location, Population, Total_Vaccinations)
as
(
Select dea.location, dea.population ,MAX(Cast(total_vaccinations as int)) as Total_Vaccinations
From CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac On
dea.location = vac.location
where dea.Continent is not null
Group By dea.location,dea.population
)
Select Location,Population,Total_Vaccinations, (Total_Vaccinations/Population)*100 as Percentage_Population_Vaccinated from LocvsVacvsPer
Order by Total_vaccinations desc


-- Temp Table
-- Country with most of its population vaccinated including all number of doses


Create Table #MostPercentagePopulationVaccinated
(
	location nvarchar(255),
	population numeric,
	total_vaccinations numeric,
)
Insert into #MostPercentagePopulationVaccinated
Select dea.location, dea.population, MAX(Cast(vac.total_vaccinations as int)) as Total_Vaccinations
from CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac
On dea.location = vac.location
where dea.continent is not null
Group by dea.location, dea.population


Select Location, Population , Total_Vaccinations , (Total_Vaccinations/Population)*100 as Percentage_Population_Vaccinated 
from #MostPercentagePopulationVaccinated
Order By Percentage_Population_Vaccinated desc


-- View 
-- Vaccinations Country wise

Create View VaccinatedPopulationCountry as
Select dea.location, MAX(Cast(vac.total_vaccinations as int)) as Total_Vaccinations
from CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac 
On dea.location =  vac.location
where dea.Continent is not null
Group by dea.location

-- Daily Death Percentage
Create View DailyDeathPercentage as
Select SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage_Daily
from CovidProject..CovidDeaths
where Continent is not null

Select * from VaccinatedPopulationCountry

Select * from DailyDeathPercentage