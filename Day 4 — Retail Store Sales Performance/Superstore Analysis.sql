Create Database Retail;
Use Retail;


CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(30),
    customer_id VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(30),
    product_id VARCHAR(30),
    category VARCHAR(30),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),
    profit_margin DECIMAL(10,2),
    order_year INT,
    order_quarter VARCHAR(10),
    discount_band VARCHAR(20)
);

LOAD DATA LOCAL INFILE 'C:/mysql_data/Superstore.csv'
INTO TABLE superstore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
row_id,
order_id,
@order_date,
@ship_date,
ship_mode,
customer_id,
segment,
country,
city,
state,
region,
product_id,
category,
sub_category,
product_name,
sales,
quantity,
discount,
profit,
profit_margin,
order_year,
order_quarter,
discount_band
)
SET
order_date = STR_TO_DATE(@order_date,'%m/%d/%Y'),
ship_date = STR_TO_DATE(@ship_date,'%m/%d/%Y');

-- Verify
SELECT COUNT(*) FROM superstore;
SELECT * FROM superstore LIMIT 5;


-- Which region has the highest and lowest total sales?

Select
Region,
count(Distinct(order_id)) As Total_Order,
Round(Sum(Sales), 2) As Total_Sales,
Round(Sum(Profit), 2) As Total_profits,
Round(Sum(Profit)/Sum(Sales) * 100, 2) As Profit_Margin_Pct,
Sum(Quantity) As Total_Quantity
From superstore
Group by Region;

-- Which product categories deliver the strongest profit margins?

Select
Category,
count(Distinct(order_id)) As Total_Order,
Round(Sum(Sales), 2) As Total_Sales,
Round(Sum(Profit), 2) As Total_profits,
Round(Sum(Profit)/Sum(Sales) * 100, 2) As Profit_Margin_Pct,
Sum(Quantity) As Total_Quantity
From superstore
Group by Category;


-- Which sub-categories are generating losses despite high sales?
Select
Category,
Sub_category,
count(Distinct(order_id)) As Total_Order,
Round(Sum(Sales), 2) As Total_Sales,
Round(Sum(Profit), 2) As Total_profits,
Round(Sum(Profit)/Sum(Sales) * 100, 2) As Profit_Margin_Pct,
Sum(Quantity) As Total_Quantity
From superstore
Group by Category, Sub_Category
Order By Profit_Margin_Pct Asc;




-- Do higher discounts actually drive higher sales volume, or just lower margin?
SELECT
  CASE
		WHEN Discount = 0 THEN '1. No Discount'
        WHEN Discount <= 0.20 THEN '2. Low (1-20%)'
        WHEN Discount <= 0.40 THEN '3. Mid (21-40%)'
        ELSE '4. High (41%+)'
  END                                             AS Discount_Band,
  COUNT(DISTINCT order_id)                         AS total_orders,
  ROUND(AVG(Sales), 2)                            AS avg_order_sales,
  ROUND(AVG(Quantity), 1)                         AS avg_quantity,
  ROUND(SUM(Profit), 2)                           AS total_profit,
  ROUND(AVG(Profit), 2)                           AS avg_profit_per_order,
  ROUND(SUM(Profit) / SUM(Sales) * 100, 2)        AS profit_margin_pct
FROM superstore
GROUP BY 
	(Case
		WHEN Discount = 0 THEN '1. No Discount'
        WHEN Discount <= 0.20 THEN '2. Low (1-20%)'
        WHEN Discount <= 0.40 THEN '3. Mid (21-40%)'
        ELSE '4. High (41%+)'
        End )
ORDER BY Discount_Band;


-- What's the sales trend by quarter — any seasonality?
select
Year(order_date) as Order_Year,
Quarter(order_date) As Order_Quarter,
concat(year(order_date),'-Q',Quarter(order_date)) As Year_Quarter,
COUNT(DISTINCT order_id)                         AS Total_Orders,
  ROUND(Sum(Sales), 2)                         AS Total_Sales,
  ROUND(SUM(Profit), 2)                           AS Total_Profit
  From superstore
  Group By YEAR(order_date),
  QUARTER(order_date),
  CONCAT(YEAR(order_date), '-Q', QUARTER(order_date))
  Order By Order_Year, Order_Quarter;
  


-- Which sub-category has the most returns or discounts applied?
select 
category,
Sub_category,
count(distinct Order_id) AS Total_Order,
Round(Avg(Discount)* 100, 1) As Avg_Discount,
Round(Sum(Profit), 2) As Total_Profit,
Round(Sum(Sales), 2) As Total_Sales
from superstore
Group By Sub_category, Category
Order By Avg_Discount desc;


  -- Customer Segment Performance
Select
segment,
count(Distinct(order_id)) As Total_Order,
Round(Sum(Sales), 2) As Total_Sales,
Round(Sum(Profit), 2) As Total_profits,
Round(Sum(Profit)/Sum(Sales) * 100, 2) As Profit_Margin_Pct,
Sum(Quantity) As Total_Quantity
From superstore
Group by segment;

-- Shipping Mode Performance

Select
ship_Mode,
count(Distinct(order_id)) As Total_Order,
Round(Sum(Sales), 2) As Total_Sales,
Round(Sum(Profit), 2) As Total_profits,
Round(Sum(Profit)/Sum(Sales) * 100, 2) As Profit_Margin_Pct,
Sum(Quantity) As Total_Quantity
From superstore
Group by ship_mode;