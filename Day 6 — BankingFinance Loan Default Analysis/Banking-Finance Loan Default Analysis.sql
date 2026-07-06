create database Banking;
Use Banking;

CREATE TABLE loan_default (
  person_age                  INT,
  person_income               DECIMAL(12,2),
  person_home_ownership       VARCHAR(20),
  person_emp_length           DECIMAL(5,1),
  loan_intent                 VARCHAR(30),
  loan_grade                  VARCHAR(5),
  loan_amnt                   DECIMAL(12,2),
  loan_int_rate               DECIMAL(5,2),
  loan_status                 INT,
  loan_percent_income         DECIMAL(5,2),
  cb_person_default_on_file   VARCHAR(5),
  cb_person_cred_hist_length  INT
);

LOAD DATA LOCAL INFILE 'C:/mysql_data/Credit Risk Dataset.csv'
INTO TABLE loan_default
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(person_age, person_income, person_home_ownership,
 person_emp_length, loan_intent, loan_grade,
 loan_amnt, loan_int_rate, loan_status,
 loan_percent_income, cb_person_default_on_file,
 cb_person_cred_hist_length);
 
 -- Verify
SELECT COUNT(*) FROM loan_default;
SELECT * FROM loan_default LIMIT 5;



-- What's the overall default rate?

SELECT
    COUNT(*) AS total_applications,
    SUM(loan_status) AS total_defaults,
    ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2) AS overall_default_rate
FROM loan_default;

-- Break it down by home ownership type too 

 Select person_home_ownership As Home_Owner,
 Count(*) As Total_Applications,
 SUM(loan_status)  AS total_defaults,
  ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2)   AS default_rate_pct,
  ROUND(AVG(loan_int_rate), 2)  AS avg_interest_rate,
  ROUND(AVG(person_income), 2)  AS avg_income
FROM loan_default
GROUP BY person_home_ownership
ORDER BY default_rate_pct DESC;


-- Default rate by loan purpose/intent

Select 
loan_intent As Loan_Purcahse,
 Count(*) As Total_Applications,
 SUM(loan_status)  AS total_defaults,
  ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2)   AS default_rate_pct,
  ROUND(AVG(loan_int_rate), 2)  AS avg_interest_rate,
  ROUND(AVG(person_income), 2)  AS avg_income
FROM loan_default
GROUP BY Loan_Purcahse
ORDER BY default_rate_pct DESC;

-- Does income level affect default rate?

Select 
Case 
    WHEN person_income < 30000  THEN '1. Low (<30k)'
    WHEN person_income < 60000  THEN '2. Mid (30k-60k)'
    WHEN person_income < 100000 THEN '3. High (60k-100k)'
    ELSE  '4. Very High (100k+)'
  END   AS Income_Band,
 Count(*) As Total_Applications,
 SUM(loan_status)  AS total_defaults,
  ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2)   AS default_rate_pct,
  ROUND(AVG(loan_int_rate), 2)  AS avg_interest_rate,
  ROUND(AVG(person_income), 2)  AS avg_income
FROM loan_default
GROUP BY Income_Band
ORDER BY default_rate_pct DESC;


-- Does loan term length affect default risk?

Select 
loan_grade As Loan_Grade,
 Count(*) As Total_Applications,
 SUM(loan_status)  AS total_defaults,
  ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2)   AS default_rate_pct,
  ROUND(AVG(loan_int_rate), 2)  AS avg_interest_rate,
  ROUND(AVG(person_income), 2)  AS avg_income
FROM loan_default
GROUP BY Loan_Grade
ORDER BY default_rate_pct DESC;


-- Does having a previous default on file predict future default?

Select 
cb_person_default_on_file As Prior_Default_On_File,
 Count(*) As Total_Applications,
 SUM(loan_status)  AS total_defaults,
  ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2)   AS default_rate_pct,
  ROUND(AVG(loan_int_rate), 2)  AS avg_interest_rate,
  ROUND(AVG(person_income), 2)  AS avg_income
FROM loan_default
GROUP BY Prior_Default_On_File
ORDER BY default_rate_pct DESC;


-- What is the average interest rate for defaulted vs non-defaulted loans?
-- Also break down by loan grade to see if pricing matches risk

SELECT
  loan_grade,
  loan_status,
  CASE WHEN loan_status = 1 THEN 'Defaulted'
       ELSE 'No Default' END                          AS default_label,
  COUNT(*)                                            AS total_loans,
  ROUND(AVG(loan_int_rate), 2)                        AS avg_interest_rate,
  ROUND(AVG(loan_amnt), 2)                            AS avg_loan_amount,
  ROUND(AVG(loan_percent_income), 2)                  AS avg_loan_to_income_ratio,
  ROUND(AVG(cb_person_cred_hist_length), 1)           AS avg_credit_history_years
FROM loan_default
GROUP BY loan_grade, loan_status
ORDER BY loan_grade, loan_status;