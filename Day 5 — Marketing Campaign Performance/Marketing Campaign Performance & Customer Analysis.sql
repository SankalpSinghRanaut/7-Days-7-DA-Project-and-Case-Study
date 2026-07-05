Create database Marketing;
Use Marketing;

-- Verfiy

select * from marketing_campaign
limit 5;
select count(*) from marketing_campaign;



-- What's the ROI (revenue / spend) by marketing channel?

select 'Campaign 1' As Campaign,
Sum(AcceptedCmp1) As Total_Acceptance,
Round(Sum(AcceptedCmp1) / Count(*) * 100, 2) As Acceptance_Rate_Pct
From marketing_campaign
union all 
	select 'Campaign 2' As Campaign,
Sum(AcceptedCmp2),
Round(Sum(AcceptedCmp2) / Count(*) * 100, 2) 
From marketing_campaign
	union all 
	select 'Campaign 3' As Campaign,
Sum(AcceptedCmp3),
Round(Sum(AcceptedCmp3) / Count(*) * 100, 2) 
From marketing_campaign

union all 
	select 'Campaign 4' As Campaign,
Sum(AcceptedCmp4),
Round(Sum(AcceptedCmp4) / Count(*) * 100, 2) 
From marketing_campaign
Order By Acceptance_Rate_Pct Desc;

--  Which customer segment (education level) responds best to campaigns?
SELECT
  Education,
  COUNT(*)                                                            AS total_customers,
  ROUND(AVG(Income), 2)                                              AS avg_income,
  ROUND(AVG(MntWines+MntFruits+MntMeatProducts+
            MntFishProducts+MntSweetProducts+MntGoldProds), 2)       AS avg_total_spend,
  SUM(AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+
      AcceptedCmp4+AcceptedCmp5)                                     AS total_campaign_responses,
  ROUND(SUM(AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+
      AcceptedCmp4+AcceptedCmp5) * 100.0 /
      (COUNT(*) * 5), 2)                                             AS response_rate_pct
FROM marketing_campaign
GROUP BY Education
ORDER BY response_rate_pct DESC;


-- Which channel drives the most purchases
SELECT
  'Web'       AS channel,
  SUM(NumWebPurchases)                                    AS total_purchases,
  ROUND(AVG(NumWebPurchases), 2)                          AS avg_per_customer
FROM marketing_campaign
UNION ALL
SELECT
  'Catalog',
  SUM(NumCatalogPurchases),
  ROUND(AVG(NumCatalogPurchases), 2)
FROM marketing_campaign
UNION ALL
SELECT
  'Store',
  SUM(NumStorePurchases),
  ROUND(AVG(NumStorePurchases), 2)
FROM marketing_campaign
ORDER BY total_purchases DESC;

-- Does higher income = higher spending and better campaign response?
SELECT
  CASE
    WHEN Income < 30000  THEN '1. Low (<30k)'
    WHEN Income < 60000  THEN '2. Mid (30k-60k)'
    WHEN Income < 90000  THEN '3. High (60k-90k)'
    ELSE                      '4. Very High (90k+)'
  END    AS income_band,
  COUNT(*)  AS total_customers,
  ROUND(AVG(Income), 2)  AS avg_income,
  ROUND(AVG(MntWines+MntFruits+MntMeatProducts+
            MntFishProducts+MntSweetProducts+MntGoldProds), 2)   AS avg_total_spend,
  ROUND(SUM(AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+
      AcceptedCmp4+AcceptedCmp5) * 100.0 / (COUNT(*) * 5), 2)    AS campaign_response_rate_pct
FROM marketing_campaign
WHERE Income IS NOT NULL
GROUP BY income_band
ORDER BY income_band;


-- What is the most purchased product category overall?


SELECT
  'Wines'       AS product_category,
  ROUND(SUM(MntWines), 2)           AS total_spend,
  ROUND(AVG(MntWines), 2)           AS avg_spend_per_customer
FROM marketing_campaign
UNION ALL
SELECT 'Meat Products', ROUND(SUM(MntMeatProducts),2),
  ROUND(AVG(MntMeatProducts),2) FROM marketing_campaign
UNION ALL
SELECT 'Gold Products', ROUND(SUM(MntGoldProds),2),
  ROUND(AVG(MntGoldProds),2) FROM marketing_campaign
UNION ALL
SELECT 'Fish Products', ROUND(SUM(MntFishProducts),2),
  ROUND(AVG(MntFishProducts),2) FROM marketing_campaign
UNION ALL
SELECT 'Sweet Products', ROUND(SUM(MntSweetProducts),2),
  ROUND(AVG(MntSweetProducts),2) FROM marketing_campaign
UNION ALL
SELECT 'Fruits', ROUND(SUM(MntFruits),2),
  ROUND(AVG(MntFruits),2) FROM marketing_campaign
ORDER BY total_spend DESC;


-- Do customers with kids at home spend less and respond less to campaigns?

SELECT
  CASE
    WHEN (Kidhome + Teenhome) = 0 THEN 'No Kids/Teens'
    WHEN (Kidhome + Teenhome) = 1 THEN '1 Kid/Teen'
    ELSE '2+ Kids/Teens'
  END                                                             AS household_type,
  COUNT(*)                                                        AS total_customers,
  ROUND(AVG(Income), 2)                                           AS avg_income,
  ROUND(AVG(MntWines+MntFruits+MntMeatProducts+
            MntFishProducts+MntSweetProducts+MntGoldProds), 2)   AS avg_total_spend,
  ROUND(SUM(AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+
      AcceptedCmp4+AcceptedCmp5) * 100.0 /
      (COUNT(*) * 5), 2)                                         AS campaign_response_rate_pct,
  ROUND(AVG(NumWebVisitsMonth), 2)                               AS avg_web_visits_per_month
FROM marketing_campaign
GROUP BY household_type
ORDER BY avg_total_spend DESC;


-- Which Country generates the highest customer purchases?

SELECT
Country,
 Round(Sum(`Total Spending`), 2) As Total_Spending,
  COUNT(*)  AS total_customers,
  SUM(NumWebPurchases)  AS total_purchases,
  ROUND(SUM(AcceptedCmp1+AcceptedCmp2+AcceptedCmp3+
      AcceptedCmp4+AcceptedCmp5) * 100.0 /
      (COUNT(*) * 5), 2)                                         AS campaign_response_rate_pct
 from marketing_campaign
 Group By Country
ORDER BY Total_Spending DESC;