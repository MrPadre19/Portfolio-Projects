Select *
From CovidDeaths
Where continent is not null
order by 3, 4


--Select *
--From CovidVaccinations
--order by 3, 4

--Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidDeaths
Where location like '%states%'
Order by 1,2



--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PercentagePopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentagePopulationInfected desc


-- Showing Countries with Highest Death Rates

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count

Select continent, sum(cast(new_deaths as int)) as ContinentDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by ContinentDeathCount desc


-- GLOBAL NUMBERS

Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/population *100)
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population *100)
From #PercentPopulationVaccinated



-- Creating View to store for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated