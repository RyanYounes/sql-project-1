select * 
from portfolioproject..coviddeaths

order by 3,4

--select*
--from portfolioproject..covidvaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..coviddeaths
order by 1,2


--looking at the total case vs total death
--show likehood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
where location like'%leba%'
order by 1,2



--looking at totalcases vs population lebanon  and  what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as casespercentage
from portfolioproject..coviddeaths
where location ='lebanon'
order by 1,2


--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as MAXinfectionCount,   max((total_cases/population))*100 as MAXpercentpopulationInfected
from portfolioproject..coviddeaths
where continent is not null 
group by location,population
order by MAXpercentpopulationInfected desc


--show the country with the highest death rate per population
select location,max(cast(total_deaths as int)) as totaldeathsCount
from portfolioproject..coviddeaths
where continent is not null
group by location
order by totaldeathsCount desc

--break think down by continent
--shoing continent with the highest deathcount 
select continent,max(cast(total_deaths as int)) as totaldeathsCount
from portfolioproject..coviddeaths
where continent is  not null
group by continent
order by totaldeathsCount desc


--global numbersa (cases,deathand % across the world)
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as Total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2

--if we want total worldwide from 2020/1 till now how many cases and deaths ACROSS THE WORLD
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as Total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2






--LOOKING AT TOTAL POPULATION THAT BEEN VACCINATED

select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 

from portfolioproject..coviddeaths  as dea
join portfolioproject..covidvaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3


--use cte

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeaplevaccinated)
as(
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 

from portfolioproject..coviddeaths  as dea
join portfolioproject..covidvaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
)

select *,(rollingpeaplevaccinated/population)*100
from popvsvac














--temp table

drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated
(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeaplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) 

from portfolioproject..coviddeaths  as dea
join portfolioproject..covidvaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 





select * ,(rollingpeaplevaccinated/population)*100
from  #percentpopulationvaccinated


-- create view to store data for ater visualisation

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)  as rollingpeaplevaccinated

from portfolioproject..coviddeaths  as dea
join portfolioproject..covidvaccinations as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select *
from percentpopulationvaccinated




