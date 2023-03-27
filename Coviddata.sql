select *
from [Portfolio Project]..coviddeaths
where continent is not null
order by 3,4

--select *
--from [Portfolio Project]..covidvaccinations
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..coviddeaths
order by 1,2

--looking for total cases vs total deaths 
select location, date, total_cases,total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
from [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
order by 1,2

--looking at total cases vs population
select location, date, population,total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
from [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
order by 1,2


--countries with highest infection rate to population

select location, population, MAX(total_cases) AS Highestinfectioncount, (CAST(MAX(total_cases) AS float)/CAST(population AS float))*100 AS PercentPopulationInfected
from [Portfolio Project]..coviddeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc

--countries with highest death count to population

select location, MAX(CAST (total_deaths as float)) AS totaldeathcount
from [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
group by location
order by totaldeathcount desc

--by continents with highest death count

select continent, MAX(CAST (total_deaths as float)) AS totaldeathcount
from [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
group by continent
order by totaldeathcount desc


--global numbers

select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF (new_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

select  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF (new_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2



select*
from [Portfolio Project]..coviddeaths dea
Join [Portfolio Project]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

	--total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from [Portfolio Project]..coviddeaths dea
Join [Portfolio Project]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--using CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from [Portfolio Project]..coviddeaths dea
Join [Portfolio Project]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac

--view for visualization

create View PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
from [Portfolio Project]..coviddeaths dea
Join [Portfolio Project]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*
from PercentPopulationVaccinated

create View DeathPercentGlobal AS
select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,SUM(CAST(new_deaths AS int))/SUM(NULLIF (new_cases,0))*100 AS DeathPercentage
FROM [Portfolio Project]..coviddeaths
--where location like '%india%'
where continent is not null
group by date

select * 
from DeathPercentGlobal