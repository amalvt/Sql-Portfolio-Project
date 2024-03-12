select * from coviddeaths 
order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population 
from coviddeaths 
order by 1,2;

--Total Cases vs Total Deaths

select location,date,total_cases,new_cases,total_deaths,
case
    when total_cases <> 0 
	then convert(float,total_deaths)/convert(float,total_cases)*100
	else null
	End as Death_percentage
from coviddeaths 
order by 1,2;

--Death_percentage in Canada

select location,date,total_cases,new_cases,total_deaths,
case
    when total_cases <> 0
	then convert(float,total_deaths)/convert(float,total_cases)*100
	else null
	End as Death_percentage
from coviddeaths 
where location like '%canada%'
order by 1,2;

--Total cases vs population

select location,date,population,total_cases,new_cases,
convert(float,total_cases)/convert(float,population)*100 as Affected_Ratio
from coviddeaths 
order by 1,2;

select location,date,population,total_cases,new_cases,
convert(float,total_cases)/convert(float,population)*100 as Affected_Ratio
from coviddeaths 
where location like '%canada%' 
order by 1,2;

--Finding countries with highest infection rate

select location,population,max(total_cases) as Highest_infection_count,
max(convert(float,total_cases)/convert(float,population)*100) as Affected_Ratio
from coviddeaths 
group by location, population
order by Affected_Ratio desc;

--Finding countries with highest death_count 

select location,max(total_deaths) as Highest_death_count
from coviddeaths 
where continent <> ''
group by location
order by Highest_death_count desc;


-- continent with highest death count

select continent,max(total_deaths) as Highest_death_count
from coviddeaths 
where continent <> ''
group by continent
order by Highest_death_count desc;

--Global Numbers

select date,
sum(cast(new_cases as float )) as total_cases,
sum(convert(float, new_deaths )) as total_deaths,
case
    when sum(new_cases) <> ''
	then Round(sum(convert(float,new_deaths)/convert(float,new_cases)*100),2)
	else null
	end as Deathpercentage
from coviddeaths
where continent is not null
group by date;


select date, SUM(CAST(new_cases as int)) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
ROUND((SUM(CAST(new_deaths as float))/NULLIF(SUM(CAST(new_cases as float)),0))*100, 2) as death_percentage
FROM coviddeaths
WHERE continent is not null
group by date


select
    date,
    SUM(CAST(new_cases AS INT)) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    ROUND((SUM(CAST(new_deaths AS FLOAT)) / NULLIF(SUM(CAST(new_cases AS FLOAT)), 0)) * 100, 2) AS death_percentage
from
    coviddeaths
where continent is not null
group by date;



--Total Poplation vs vaccinations

select * from coviddeaths death join covidvaccinations vacc
on death.location = vacc.location 
and death.date=vacc.date
where death.continent is not null
order by 1,2,3;

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
from coviddeaths death
JOIN covidvaccinations vacc
on death.location = vacc.location
and death.date = vacc.date
where death.continent <> ''
order by 2,3;


--using CTE
with popvsdeath as 
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(convert(bigint, vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as cumulative_vaccinations
from coviddeaths death
join covidvaccinations vacc 
on death.location = vacc. location
and death.date = vacc.date
where death.continent <> ''
)
select * ,(convert(float,cumulative_vaccinations))/(convert(float,population))*100 as vaccination_percentage 
from popvsdeath
where population > 0;



with popvsdeath as 
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(convert(bigint, vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as cumulative_vaccinations
from coviddeaths death
join covidvaccinations vacc 
on death.location = vacc. location
and death.date = vacc.date
where death.continent <> ''
)
select * ,(convert(float,cumulative_vaccinations))/(convert(float,population))*100 as vaccination_percentage 
from popvsdeath
where population > 0
and location like '%Canada%';



--creating view to store data for later visulization

create view vaccinatedpopratio as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
sum(convert(bigint, vacc.new_vaccinations)) over (partition by death.location order by death.location, death.date)
as cumulative_vaccinations
from coviddeaths death
join covidvaccinations vacc 
on death.location = vacc. location
and death.date = vacc.date
where death.continent <> '';

select * from vaccinatedpopratio;


-- tableau tables query

select
sum(cast(new_cases as float)) as total_cases,
sum(cast(new_deaths as float)) as total_deaths,
round(sum(cast(new_deaths as float)) / nullif(sum(cast(new_cases as float)), 0) * 100, 2) as deathpercentage
from coviddeaths
where continent is not null;

select continent,
sum(cast(new_deaths as int)) as totaldeathcount
from coviddeaths
where continent is not null and location not in ('World', 'European Union', 'International')
group by continent
order by totaldeathcount desc;

select location,population,
max(total_cases) as higest_infection_count,
(max(total_cases) / nullif(convert(float, population), 0)) * 100 as population_infected_ratio
from coviddeaths
group by location, population
order by population_infected_ratio desc;

select location, population,date,
max(total_cases) as highestinfectioncount,
max((total_cases / nullif(convert(float, population), 0)) * 100) as percentpopulationinfected
from coviddeaths
group by location, population, date
order by percentpopulationinfected desc;

