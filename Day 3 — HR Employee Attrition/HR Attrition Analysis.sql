Create Database HR;
Use HR;

-- Verfiy
SELECT COUNT(*) FROM hr_attrition;
Select * from hr_attrition
limit 5;


-- What's the overall attrition rate, and how does it vary by department?

Select
Count(*) As Total_Employees,
Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition;

Select
Department,
Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Department
Order By Attrition_Rate_Pct Desc;

-- Does attrition correlate with low job satisfaction scores?
Select 
JobSatisfaction,
Case 
	When JobSatisfaction = 1 Then 'Low'
    When JobSatisfaction = 2 Then 'Medium'
    When JobSatisfaction = 1 Then 'High'
    Else 'Very High'
    End As Satisfaction_Label,
    Count(*) As Total_Employees,
    Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
from hr_attrition
Group By JobSatisfaction;

-- Is attrition higher for employees with longer commute distances?

Select
Case
	When DistanceFromHome <= 5 Then 'Near (1-6)'
    When DistanceFromHome <= 15 Then 'Mid (6-15)'
    Else 'Far (16+)'
    End As Commute_Band,
 Count(*) As Total_Employees,
    Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Commute_Band;


-- How does attrition differ by salary band?
Select
Case
	When MonthlyIncome < 3000 Then '1. Low (<3k)'
    When MonthlyIncome <  7000 Then '2. Mid (3k-7k)'
    When MonthlyIncome <  12000 Then '3. High (7k-12k)'
    Else '4.Very High (12k+)'
    End As Salary_Band ,
 Count(*) As Total_Employees,
    Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Salary_Band
Order By Salary_Band asc;

-- Is there a tenure "danger zone" (e.g., year 1-2) where most people leave?

Select
Case
	When YearsAtCompany <= 2 Then '0-2 Years'
    When YearsAtCompany <= 5 Then '3-5 Years'
    When YearsAtCompany <= 10 Then '5-10 Years'
    Else '10+ Years'
    End As Tenure_Band ,
 Count(*) As Total_Employees,
    Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Tenure_Band
Order By Attrition_Rate_Pct desc;

-- Which job role has the highest attrition?
Select
JobRole,
Count(*) As Total_Employees,
Round(Avg(MonthlyIncome), 2) As Avg_Monthly_Income,
Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By JobRole
Order By Attrition_Rate_Pct Desc;

-- By Gender & Marital Status
Select
Gender, MaritalStatus, 
Count(*) As Total_Employees,
Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Gender, MaritalStatus 
Order By Attrition_Rate_Pct desc;

-- By Age Band
Select
Case
	When ï»¿Age <= 25 Then '18–25 Early-career employees'
    When ï»¿Age <= 35 Then '26-35 Young professionals (typically highest attrition)'
    When ï»¿Age <= 45 Then '36–45 Mid-career employees'
    When ï»¿Age <= 55 Then '46–55 Senior professionals'
    Else '56+ Pre-retirement employees'
    End As Age_Band ,
 Count(*) As Total_Employees,
    Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) as Attrited,
Round(Sum(Case When Attrition = 'Yes' Then 1 Else 0 End) * 100 / Count(*), 2) As Attrition_Rate_Pct
From hr_attrition
Group By Age_Band
Order By Attrition_Rate_Pct desc;
