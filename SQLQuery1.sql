CREATE TABLE hr_att (
    Age INT,
    Attrition VARCHAR(10),
    BusinessTravel VARCHAR(20),
    DailyRate INT,
    Department VARCHAR(50),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(50),
    EmployeeCount INT,
    EmployeeNumber INT,
    EnvironmentSatisfaction INT,
    Gender VARCHAR(10),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(50),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(20),
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(10),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

BULK INSERT hr_att
FROM 'C:\Users\VISH NU\Downloads\WA_Fn-UseC_-HR-Employee-Attrition.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Attrition Rate
SELECT 
    Attrition, 
    COUNT(*) AS TotalEmployees,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hr_att)) AS AttritionPercentage
FROM hr_att
GROUP BY Attrition;

-- Gender Distribution by Attrition Rate
SELECT 
    Gender, 
    COUNT(*) AS Count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hr_att)) AS GenderPercentage
FROM hr_att
GROUP BY Gender;

-- Over Time -> Attrition
SELECT 
    OverTime,
    COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS AttritionRate
FROM hr_att
GROUP BY OverTime
ORDER BY AttritionRate DESC;

-- Distance from home -> Attrition
SELECT 
    DistanceFromHome, 
    COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS AttritionRate
FROM hr_att
GROUP BY DistanceFromHome
ORDER BY DistanceFromHome;

--Identifying high-attrition departments or job roles
SELECT Department, JobRole, COUNT(*) AS TotalAttrition
FROM hr_att
WHERE Attrition = 'Yes'
GROUP BY Department, JobRole
ORDER BY TotalAttrition DESC;

--Ranking high-attrition based on department or job role
--Department
WITH DeptAttrition AS (
    SELECT 
        Department,
        CEILING(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
    FROM hr_att
    GROUP BY Department
)
SELECT 
    Department, 
    AttritionRate,
    RANK() OVER (ORDER BY AttritionRate DESC) AS AttritionRank
FROM DeptAttrition;

--Job role
WITH RoleAttrition AS (
    SELECT 
        JobRole, 
        CEILING(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
    FROM hr_att
    GROUP BY JobRole
)
SELECT 
    JobRole,
    AttritionRate,
	RANK() OVER (ORDER BY AttritionRate DESC) AS AttritionRank
FROM RoleAttrition;

-- Performance Ratings across Job roles
SELECT 
    JobLevel, 
    AVG(PerformanceRating) AS AvgPerformanceRating
FROM hr_att
GROUP BY JobLevel
ORDER BY JobLevel;

-- From previous observation senior positions are less likely for attrition, So lets check with the Job role
WITH RoleAttrition AS (
    SELECT 
        JobRole, 
		JobLevel,
        CEILING(COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
    FROM hr_att
    GROUP BY JobRole, JobLevel
)
SELECT 
    JobRole, 
	JobLevel,
    AttritionRate,
	RANK() OVER (ORDER BY AttritionRate DESC) AS AttritionRank
FROM RoleAttrition;

/* 
Higher level job roles like Exceutive, Director or Manager are less 
likely for retention in all departments except for Sales department
*/

-- Top 5 Employees with Highest Monthly Income
SELECT TOP 10
	EmployeeNumber,
	JobLevel,
	JobRole,
	YearsInCurrentRole,
	Department,
	MonthlyIncome
FROM hr_att 
ORDER BY MonthlyIncome DESC;


-- Job satisfaction based on department
SELECT 
    Department,
    AVG(JobSatisfaction) AS AvgJobSatisfaction
FROM hr_att
GROUP BY Department;

-- employees eligible for promotion
SELECT 
    EmployeeNumber,
    YearsSinceLastPromotion,
    JobLevel
FROM hr_att
WHERE YearsSinceLastPromotion > 3;

-- Rank department based on average work life balance
SELECT 
    Department,
    AVG(WorkLifeBalance) AS AvgWorkLifeBalance,
    RANK() OVER (ORDER BY AVG(WorkLifeBalance) DESC) AS WorkLifeBalanceRank
FROM hr_att
GROUP BY Department;

--Job level vs Monthly Income
SELECT 
    JobLevel,
    AVG(MonthlyIncome) AS AvgMonthlyIncome
FROM hr_att
GROUP BY JobLevel
ORDER BY JobLevel;

-- Employees in departments with above average performance
WITH DeptPerformance AS (
    SELECT 
        Department,
        AVG(PerformanceRating) AS AvgDeptPerformance
    FROM hr_att
    GROUP BY Department
)
SELECT 
    e.EmployeeNumber,
    e.Department,
    e.PerformanceRating
FROM hr_att e
INNER JOIN DeptPerformance dp ON e.Department = dp.Department
WHERE e.PerformanceRating > dp.AvgDeptPerformance;

