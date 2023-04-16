SELECT
*
FROM
PortfolioProject..Covid_Deaths$
ORDER BY 
3,4;

SELECT
*
FROM
PortfolioProject..Covid_Vaccinations$
ORDER BY 
3,4;
---Selecting data that we going to be using-----
SELECT
     location,date,total_cases,new_cases,total_deaths,population
FROM
PortfolioProject..Covid_Deaths$
ORDER BY 
1,2;
------Looking at total deaths Vs total cases------
SELECT
     location,date,total_cases,total_deaths,(Cast(total_deaths as float)/CAST(total_cases as float))*100
FROM
PortfolioProject..Covid_Deaths$
ORDER BY 
1,2;
SELECT
     location,date,total_cases,total_deaths ,(Cast(total_deaths as float)/CAST(total_cases as float))*100
FROM
PortfolioProject..Covid_Deaths$
WHERE  total_deaths Is not Null 
ORDER BY 
1,2;

SELECT
     location,date,total_cases,total_deaths, (Cast(total_deaths as float)/CAST(total_cases as float))*100 as Death_Percentage
FROM
PortfolioProject..Covid_Deaths$
WHERE location like'%states%'
ORDER BY 
1,2; 
 SELECT
     location,date,total_cases,total_deaths, (Cast(total_deaths as float)/CAST(total_cases as float))*100 as Death_Percentage
FROM
PortfolioProject..Covid_Deaths$
WHERE  total_deaths Is not Null AND location like '%India%'
ORDER BY 
1,2;
-----Looking at total cases Vs Population-----
------ Showing what percentage of population got covid---
SELECT
     location,date,total_cases,population, (Cast(total_cases as float)/population)*100 as Cases_Percentage
FROM
PortfolioProject..Covid_Deaths$
ORDER BY 
1,2;

SELECT
     location,date,total_cases,population, (Cast(total_cases as float)/population)*100 as Cases_Percentage
FROM
PortfolioProject..Covid_Deaths$
WHERE  location like '%States%'
ORDER BY 
1,2;

-----Looking at countries with highest infection rate compared to population-----
SELECT
     location, population, Max(cast(total_cases as float)) As HighestInfectionCount,Max((Cast(total_cases as float)/population))*100 as Cases_Percentage
FROM
PortfolioProject..Covid_Deaths$
Group by location,population
ORDER BY 
1,2;
----Showing countries with Highest Death Count per population---
SELECT
     location,MAX(cast(total_deaths as float)) As TotalDeathCount
FROM
PortfolioProject..Covid_Deaths$
Where continent is not null
Group By location
Order By   
TotalDeathCount Desc;
----Let's break things down by Continents------
-----Showing continents with highest death count per population(we want to start looking at this from a viewpoint of i'm going to visualise this)----
SELECT
     location,MAX(cast(total_deaths as float)) As TotalDeathCount
FROM
PortfolioProject..Covid_Deaths$
Where continent is  null
Group By location
Order By   
TotalDeathCount Desc;

--------GLOBAL NUMBERS-----
SELECT
     date,SUM(new_cases) as Total_cases,SUM(new_deaths) as Total_deaths ,SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM
PortfolioProject..Covid_Deaths$
WHERE continent is not null and new_cases <> 0
GROUP BY date
ORDER BY 
1,2;
SELECT
     SUM(new_cases) as Total_cases,SUM(new_deaths) as Total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as death_percentage
FROM
PortfolioProject..Covid_Deaths$
WHERE continent is not null
ORDER BY 
1,2;

Select
location,sum(cast(new_deaths as float)) as TotalDeathCounts
From PortfolioProject..Covid_Deaths$
Where continent is null
 and location not in('World','European Union','International','Upper middle income','High Income','Lower middle income','Low Income')
 Group by location
 Order by TotalDeathCounts DESC;
------Looking at Total population VS Vaccination-------
-----Here we want to know total amount of people that have been vaccinated in the world-------
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.date ) as RollingPeopleVaccinated  
 from  PortfolioProject..Covid_Deaths$ as dea
 JOIN PortfolioProject..Covid_Vaccinations$ as vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;
---------- Use CTE-------- 
WITH PopvsVac 
AS
( select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.date ) as RollingPeopleVaccinated 
 from  PortfolioProject..Covid_Deaths$ as dea
 JOIN PortfolioProject..Covid_Vaccinations$ as vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null)
 --order by 2,3
 SELECT*,(RollingPeopleVaccinated/population)*100 as EverydayPercentVaccinated
 from PopvsVac
 Where new_vaccinations is not null;
 ----------Temp Table-------
 Drop table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated
 (Continent nvarchar(255),
 Location nvarchar(255),Date Datetime,
 Population numeric,New_Vaccinations  numeric,
 RollingPeopleVaccinated numeric)

 Insert Into #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.date ) as RollingPeopleVaccinated 
 from  PortfolioProject..Covid_Deaths$ as dea
 JOIN PortfolioProject..Covid_Vaccinations$ as vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,3;
  SELECT*,(RollingPeopleVaccinated/population)*100 as EverydayPercentVaccinated
 from #PercentPopulationVaccinated
 Where new_vaccinations is not null;


--------Creating Views-----
-------Creating first view--------
Create View   PercentPopulationVaccinated as 
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.date ) as RollingPeopleVaccinated 
 from  PortfolioProject..Covid_Deaths$  as dea
 JOIN PortfolioProject..Covid_Vaccinations$ as vac
 ON dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null;

 Select *
 FROM PercentPopulationVaccinated;
  
  -------Creating second view------
CREATE VIEW  
India_Death_To_Cases_ratio as
 SELECT
     location,date,total_cases,total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float))*100 as Death_Percentage
FROM
PortfolioProject..Covid_Deaths$ 
WHERE  total_deaths Is not Null AND location like '%India%';
 select *
 from India_Death_To_Cases_ratio


 


