Select * from portfolioproject..DEATH
order by 3,4
Select * from portfolioproject..VACCINATION$
order by 3,4
--data to be used
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..DEATH
order by 1,2


--finding out how many cases lead to death

alter table portfolioproject..DEATH
alter column total_deaths dec;
alter table portfolioproject..DEATH
alter column total_cases dec;

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
order by 1,2

--finding out DEATHPERCENTAGE in india 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
where location ='india'
order by 1,2

--finding out the percentage of people got covid
select location,date,total_cases,population,(total_cases/population)*100 as CASEPERCENTAGE
from portfolioproject..DEATH
order by 1,2
--In india
select location,date,total_cases,population,(total_cases/population)*100 as CASEPERCENTAGE
from portfolioproject..DEATH
where location='INDIA'
order by 1,2

--finding out the country with highest infection rate compared to population

select location,max(total_cases) as highest_infection,population,max(total_cases/population)*100 as CASEPERCENTAGE
from portfolioproject..DEATH
group by location,population
order by  CASEPERCENTAGE desc

--finding out countries with highest death rate compared to population
select location,max(total_deaths) as highdeathrate,population,max(total_deaths/population)*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
group by population,location
order by DEATHPERCENTAGE desc

    -- by continent
select continent,max(total_deaths) as highdeathrate,max(total_deaths/population)*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
where continent is not null
group by continent
order by DEATHPERCENTAGE desc

--getting insights from global numbers
select  sum(new_cases)as totalcases,sum(new_deaths)as totaldeaths,sum(new_deaths)/sum(nullif(new_cases,0))*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
order by 1,2

--joining death and vaccination table by location and date
select*
from portfolioproject..DEATH d
join portfolioproject..VACCINATION$ v
on D.location=V.location
and D.date=V.date 

--looking at total population vs vaccination
with popvsvac (location,date,new_vaccinations,continent,rollingcount,population)
as
(
select d.continent,d.location,d.date,v.new_vaccinations,v.population
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rollingcount
from portfolioproject..DEATH d
join portfolioproject..VACCINATION$ v
on D.location=V.location
and D.date=V.date 
where d.continent is not null
)
select *,(nullif(rollingcount,0)/(population)*100)
from popvsvac

--Temp table
drop table if exists percentageofpeoplevaccinated
create table percentageofpeoplevaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into percentageofpeoplevaccinated
select d.continent,d.location,d.date,v.new_vaccinations,v.population
,sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rollingcount
from portfolioproject..DEATH d
join portfolioproject..VACCINATION$ v
on D.location=V.location
and D.date=V.date 
where d.continent is not null

--creating views to store data
create view deathpercentindia as
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DEATHPERCENTAGE
from portfolioproject..DEATH
where location ='india'

select * from
deathpercentindia
