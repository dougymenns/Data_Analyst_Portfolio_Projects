---select data we are going to be using
select location,date,total_cases,new_cases,total_deaths,population 
from public."CovidDeaths"
order by location,date

---total cases vs total deaths(death percentage per total cases)
---looking at current date for us, there is 1.6% chance of dying per 46 mill cases
---shows the likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from public."CovidDeaths"
where location like '%States%'
order by location,date


---total cases vs population
---shows what percentage of population got covid
---presently, 13.9% of the US population got covid
select location,date,total_cases,population, (total_cases/population)*100 as Population_Per_Cases_Percentage
from public."CovidDeaths"
where location like '%States%'
order by location,date

---looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Population_Per_Cases_Percentage
from public."CovidDeaths"
group by location,population
order by Population_Per_Cases_Percentage desc

---countries with highest death count
select location,max(total_deaths) as Highest_Death_Count
from public."CovidDeaths"
where continent is not null
group by location
having max(total_deaths) is not null
order by Highest_Death_Count desc

---countries with highest death count per population
select location,population,max(total_deaths) as Highest_Death_Count, max((total_deaths/population))*100 as Population_Per_Deaths_Percentage
from public."CovidDeaths"
group by location,population
order by Population_Per_Deaths_Percentage desc

---countries with highest death count
select continent,max(total_deaths) as Total_Death_Count
from public."CovidDeaths"
where continent is not null
group by continent
order by Total_Death_Count desc

---showing continent with highest death count (correct)
select location,max(total_deaths) as Highest_Death_Count
from public."CovidDeaths"
where continent is null
group by location
having location not in ('High income','Upper middle income','Lower middle income','Low income','International')
order by Highest_Death_Count desc

---Global Numbers
---death percentage by date
select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) *100 as Death_Percentage--,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from public."CovidDeaths"
where continent is not null
group by date
order by date
---total world death percentage
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) *100 as Death_Percentage--,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from public."CovidDeaths"
where continent is not null

---looking at total vaccination vs population
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/death.population)*100
from public."CovidDeaths" death
join  public."CovidVaccinations"  vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
order by death.location, death.date 

---use cte
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/death.population)*100
from public."CovidDeaths" death
join  public."CovidVaccinations"  vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as Vaccination_Per_Population from PopvsVac

---temp table for RollingPeopleVaccinated
Drop table if exists public."#PercentPopulationVaccinated";
create table public."#PercentPopulationVaccinated"(
continent varchar,
location varchar,
date varchar,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
);
insert into public."#PercentPopulationVaccinated"
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from public."CovidDeaths" death
join  public."CovidVaccinations"  vac
on death.location = vac.location and death.date = vac.date

---creating view to store data for later viz
create view public."PercentPopulationVaccinated" as 
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
from public."CovidDeaths" death
join  public."CovidVaccinations"  vac
on death.location = vac.location and death.date = vac.date
where death.continent is not null

