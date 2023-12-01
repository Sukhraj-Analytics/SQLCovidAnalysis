
Select * 
From PortfolioProject1..CovidDeaths

-- Select Data that is neccesary

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order By 1,2

-- Total Cases vs Total Deaths in Canada

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death rate]
From PortfolioProject1..CovidDeaths
Where Location = 'Canada'
Order By 1,2

-- Total Cases vs Population in Canada

Select Location, date, total_cases, population, (total_cases/population)*100 as [Infection rate]
From PortfolioProject1..CovidDeaths
Where Location = 'Canada'
Order By 1,2

-- Countries with Highest infection rate compared to population

Select Location, population,date, MAX(total_cases) as [Greatest Infection Count], MAX((total_cases/population))*100 as [Percent of Population Infected]
From PortfolioProject1..CovidDeaths
Group By Location, Population, date
Order By [Percent of Population Infected] desc


-- Countries with Highest Death Count per Population

Select Location, population, MAX(cast(total_deaths as int)) as [Total Deaths], MAX((total_deaths/population))*100 as [Percent of Deaths]
From PortfolioProject1..CovidDeaths
where continent is not null
Group By location, population
Order By [Percent of Deaths] desc

-- Continents with Highest Death Count per Population

Select Location, population, MAX(cast(total_deaths as int)) as [Total Deaths], MAX((total_deaths/population))*100 as [Percent of Deaths]
From PortfolioProject1..CovidDeaths
where continent is null
Group By location, population
Order By [Total Deaths] desc

-- Total Deaths per Continent

Select continent, MAX(cast(total_deaths as int)) as [Total Deaths]
From PortfolioProject1..CovidDeaths
where continent is not null
Group By continent
Order By [Total Deaths] desc

-- Global Cases/Deaths/Death Rate per day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as[Death rate]
From PortfolioProject1..CovidDeaths
where continent is not null
Group By date
Order By 1,2


-- Total Global Cases/Deaths/Death Rate

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as[Death rate]
From PortfolioProject1..CovidDeaths
where continent is not null


-- Joining Covid Vaccination data to Covid Death data

Select *
From PortfolioProject1..CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date

-- Vaccinated Population per Day using two methods.

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Total_Vaccinations)
as 
(
Select CovidDeaths.continent, CovidDeaths.location,	CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as Total_Vaccinations
From PortfolioProject1..CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location 
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
-- and CovidDeaths.location = 'Canada'
)
Select *, (Total_Vaccinations/Population)*100 as PercentOfPopulationVaccinated
From PopvsVac


-- Temp table method

DROP TABLE if exists PercentPopVaccinated
Create Table PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinations numeric
)

Insert into PercentPopVaccinated
Select CovidDeaths.continent, CovidDeaths.location,	CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as Total_Vaccinations
From PortfolioProject1..CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location 
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--and CovidDeaths.location = 'Canada'
Select *, (Total_Vaccinations/Population)*100 as PercentOfPopulationVaccinated
From PercentPopVaccinated


-- Views

Create View PercentPopulationVaccinated as
Select CovidDeaths.continent, CovidDeaths.location,	CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as Total_Vaccinations
From PortfolioProject1..CovidDeaths
Join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location 
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null