-- Select *
-- From portfolio_project..covid_vaccinations_dataset$
-- Order By 3,4


-- Select the data that we are using 

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio_project..covid_deaths_dataset$
Where continent is not null
Order By 1,2


-- Looking at total cases and total deaths in each country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From portfolio_project..covid_deaths_dataset$
Where location = 'India' and continent is not null
Order By 1,2

-- Looking at total cases and population
-- Shows the percentage of people infected with covid

Select Location, date, total_cases, population, (total_cases/population)*100 as infected_population
From portfolio_project..covid_deaths_dataset$
Where location = 'India' and continent is not null
Order By 1,2

-- Looking at countries which have highest infection rate based on population

Select Location, MAX(total_cases) as Highest_infection_rate, population, MAX((total_cases/population))*100 as percent_infected_population
From portfolio_project..covid_deaths_dataset$
Where continent is not null
group by population, location
Order By percent_infected_population desc

-- Countries having the highest deaths

Select Location,MAX(cast(total_deaths as int)) as total_death_count
From portfolio_project..covid_deaths_dataset$
Where continent is not null
group by location
Order By total_death_count desc

-- Continents having the highest deaths

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From portfolio_project..covid_deaths_dataset$
Where continent is not null
group by continent
Order By total_death_count desc

-- Global numbers

Select date, SUM(new_cases) as sum_total_new_cases, SUM(cast(new_deaths as int)) as sum_total_new_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as global_death_percentage
From portfolio_project..covid_deaths_dataset$
Where continent is not null
Group by date
Order By 1,2

-- Global death percentage

Select SUM(new_cases) as sum_total_new_cases, SUM(cast(new_deaths as int)) as sum_total_new_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as global_death_percentage
From portfolio_project..covid_deaths_dataset$
Where continent is not null
Order By 1,2

-- Joining covid_ deaths and covid_vaccinations table

Select *
From portfolio_project..covid_deaths_dataset$ dea
  Join portfolio_project..covid_vaccinations_dataset$ vac
  On dea.location = vac.location
  and dea.date = vac.date


-- looking at total population and vaccinations
-- Using CTE


With popandvac (continent, Location, date, population, new_vaccinations, rolling_vaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccination
--, (rolling_vaccination/population)*100
From portfolio_project..covid_deaths_dataset$ dea
  Join portfolio_project..covid_vaccinations_dataset$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
--order by 2,3
)
Select *, (rolling_vaccination/population)*100 as rolling_percentage
From popandvac


-- Using temporary table


Drop Table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_vaccination numeric
)
Insert Into #PercentPopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location
, dea.date) as rolling_vaccination
--, (rolling_vaccination/population)*100
From portfolio_project..covid_deaths_dataset$ dea
  Join portfolio_project..covid_vaccinations_dataset$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
-- order by 2,3

Select *, (rolling_vaccination/population)*100 as rolling_percentage
From #PercentPopulationvaccinated


-- Creating views to store data

Create View PercentPopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location
, dea.date) as rolling_vaccination
--, (rolling_vaccination/population)*100
From portfolio_project..covid_deaths_dataset$ dea
  Join portfolio_project..covid_vaccinations_dataset$ vac
  On dea.location = vac.location
  and dea.date = vac.date
  Where dea.continent is not null
