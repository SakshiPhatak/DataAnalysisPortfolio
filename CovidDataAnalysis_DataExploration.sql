select * 
from PortfolioProjectCovid..CovidDeaths
order by 3,4

--select * 
--from PortfolioProjectCovid..CovidVaccinations
--order by 3,4

select location, date, total_cases,new_cases, total_deaths, population
from PortfolioProjectCovid..CovidDeaths
order by 1,2

--looking at total cases v/s total deaths

--likelihood of dying after contracting covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths where location like '%india%'
order by 1,2

--looking at total cases v/s population
-- what percentage of population got covid in your country

select location, date, total_cases, population, (total_cases/population)*100 as CovidContractPercentage
from PortfolioProjectCovid..CovidDeaths
where location like '%india%'
order by 1,2

--countries with highest infection rate

select location, population, total_cases, (total_cases/population)*100 as CovidContractPercentage
from PortfolioProjectCovid..CovidDeaths
order by 4 desc

select location, population, max(total_cases) as HighestCountOfInfections, max((total_cases/population)*100) as MaxCovidContractPercentage
from PortfolioProjectCovid..CovidDeaths
group by location,population
order by 4 desc

--countries with highest death rate


select location, population, max(total_deaths) as HighestCountOfDeaths, max((total_deaths/population)*100) as MaxCovidDeathsPercentage
from PortfolioProjectCovid..CovidDeaths
group by location,population
order by 4 desc

--countries with highest death count with population


select location, max(cast(total_deaths as int)) as HighestCountOfDeaths
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by location 
order by 2 desc



--continents with highest death count with population


select continent, max(cast(total_deaths as int)) as HighestCountOfDeaths
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by continent 
order by 2 desc


select location, max(cast(total_deaths as int)) as HighestCountOfDeaths
from PortfolioProjectCovid..CovidDeaths
where continent is null --and location like '%income%'
group by location 
order by 2 desc

-- deleted redundant data items
delete from PortfolioProjectCovid..CovidDeaths
where continent is null and location like '%income%'


--Global numbers

select date,sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
group by date
order by 1,2


select sum(new_cases) as TotalNewCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjectCovid..CovidDeaths
where continent is not null
--group by date
order by 1,2


select * 
from PortfolioProjectCovid..CovidVaccinations
order by 3,4


--Join 2 tables

select * 
from PortfolioProjectCovid..CovidDeaths d
join PortfolioProjectCovid..CovidVaccinations v
on d.location=v.location and d.date = v.date
--order by 3,4

--Total Population v/s Vaccinations

select d.continent,d.location,d.date,d.population, v.new_vaccinations
from PortfolioProjectCovid..CovidDeaths d
join PortfolioProjectCovid..CovidVaccinations v
on d.location=v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- cummulative sum of vaccinations as per the location
 
select d.continent,d.location,d.date,d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location) countVacc
from PortfolioProjectCovid..CovidDeaths d
join PortfolioProjectCovid..CovidVaccinations v
on d.location=v.location and d.date = v.date
where d.continent is not null
order by 2,3

--select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
--SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingVacci
--from PortfolioProjectCovid..CovidDeaths dea
--join PortfolioProjectCovid..CovidVaccinations vac
--on dea.location=vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select d.location,d.date, d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.date)
from PortfolioProjectCovid..CovidDeaths d
join PortfolioProjectCovid..CovidVaccinations v
on d.location=v.location and d.date = v.date
where d.continent is not null
order by 1,2


select location,date ,new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by location order by date)
from PortfolioProjectCovid..CovidVaccinations
where continent is not null



---------------------------------------------------------
-- find cummulative using self join


select location,date ,new_vaccinations,
 (  Select sum(cast(new_vaccinations as bigint)) 
  from PortfolioProjectCovid..CovidVaccinations S2
                   Where S2.date<= S1.date and
                   S2.location=S1.location
                )  RollingVaccinationCount
                from PortfolioProjectCovid..CovidVaccinations S1
                order by S1.location, S1.date
                


select d1.location,d1.date,d1.population ,v1.new_vaccinations,
 (  Select sum(cast(new_vaccinations as bigint)) 
  from PortfolioProjectCovid..CovidDeaths d2
join PortfolioProjectCovid..CovidVaccinations v2
on d2.location=v2.location and d2.date = v2.date
                   Where d2.date<= d1.date and
                   d2.location=d1.location
                )  RollingVaccinationCount
                from PortfolioProjectCovid..CovidDeaths d1
join PortfolioProjectCovid..CovidVaccinations v1
on d1.location=v1.location and d1.date = v1.date
                order by d1.location, d1.date
                


---------------------------------------------------

--With CTE

with PopvsVac (continent,location,date,new_vaccinations,RollingVaccinationCount)as
(
	select continent,location,date ,new_vaccinations,
 (  Select sum(cast(new_vaccinations as bigint)) 
  from PortfolioProjectCovid..CovidVaccinations S2
                   Where S2.date<= S1.date and
                   S2.location=S1.location
                )  RollingVaccinationCount
                from PortfolioProjectCovid..CovidVaccinations S1
               --order by S1.location, S1.date
)
select p.continent,p.location,p.date,d.population,p.new_vaccinations,
p.RollingVaccinationCount,(p.RollingVaccinationCount/d.population)*100 as PopulationvsVaccinationPercent 
from PopvsVac p join PortfolioProjectCovid..CovidDeaths d
on p.date=d.date and p.location=d.location



-----------------------------------------

--with temp table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
rolling_vaccination_count numeric)

insert into #PercentPopulationVaccinated
select continent,location,date ,new_vaccinations,
 (  Select sum(cast(new_vaccinations as bigint)) 
  from PortfolioProjectCovid..CovidVaccinations S2
                   Where S2.date<= S1.date and
                   S2.location=S1.location
                )  RollingVaccinationCount
                from PortfolioProjectCovid..CovidVaccinations S1
               --order by S1.location, S1.date

select p.continent,p.location,p.date,d.population,p.new_vaccinations,
p.rolling_vaccination_count,(p.rolling_vaccination_count/d.population)*100 as PopulationvsVaccinationPercent 
from #PercentPopulationVaccinated p join PortfolioProjectCovid..CovidDeaths d
on p.date=d.date and p.location=d.location


-------------------------------------------

--Creating views for visualization


Create View CountPopulationVaccinated as 
select continent,location,date ,new_vaccinations,
 (  Select sum(cast(new_vaccinations as bigint)) 
  from PortfolioProjectCovid..CovidVaccinations S2
                   Where S2.date<= S1.date and
                   S2.location=S1.location
                )  RollingVaccinationCount
                from PortfolioProjectCovid..CovidVaccinations S1
               --order by S1.location, S1.date

drop view PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
select p.continent,p.location,p.date,d.population,p.new_vaccinations,
p.RollingVaccinationCount,(p.RollingVaccinationCount/d.population)*100 as PopulationvsVaccinationPercent 
from CountPopulationVaccinated p join PortfolioProjectCovid..CovidDeaths d
on p.date=d.date and p.location=d.location

select * from PercentPopulationVaccinated


