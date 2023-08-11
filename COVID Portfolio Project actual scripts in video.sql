--Select *
--From PortfolioProject.dbo.CovidDeaths
--Where continent is not null
--order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select data that we are going to be using


--Select Location, Date, new_cases, total_deaths, population
--From PortfolioProject.dbo.CovidDeaths
--order by 1,2

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DealthPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2


--Looking at total cases vs population
--shows what population got covid

Select Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighesInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group By continent, population
order by PercentPopulationInfected DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
Group By continent
order by TotalDeathCount DESC


--Global numbers

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/
SUM(New_Cases)*100 as DealthPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
Group By date
order by 1,2

--Looking at total population vs vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated


