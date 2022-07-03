-- Tableau Queries for dashboard

--1
Select SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as int)) as Total_Deaths, (SUM(Cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage
From CovidProject..CovidDeaths
where Continent is not null

--2
Select dea.location, MAX(Cast(vac.total_vaccinations as int)) as Total_Vaccinations
from CovidProject..CovidDeaths dea JOIN CovidProject..CovidVaccinations vac 
On dea.location =  vac.location
where dea.Continent is not null
Group by dea.location

--3
Select Continent ,SUM(new_cases) as Total_Cases
From CovidProject..CovidDeaths
where continent is not null
Group by Continent

--4
Select Location, population, SUM(new_cases) as Total_Infected, (Sum(new_cases)/Population)*100 as Percentage_People_Infected
From CovidProject..CovidDeaths
where continent is not null
Group by Location , Population
Order by Percentage_People_Infected desc 

--5
Select Location, population, date, MAX(total_cases) as Total_Infected, (MAX(total_cases)/Population)*100 as Percentage_People_Infected
From CovidProject..CovidDeaths
where continent is not null
Group by Location , Population, date
Order by Percentage_People_Infected desc 


