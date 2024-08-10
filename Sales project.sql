-- Data exploration --
select * 
from sales 
limit 100;

-- Step 2: Data Cleaning and Preprocessing --

-- Check for Missing or NULL  Values

select count(*) 
from sales 
where MyUnknownColumn is null or
Order_ID  is null or
Product is null or
Quantity_Ordered is null or
Price_Each is null or
Order_Date is null or
Purchase_Address is null or
Month_num  is null or
Sales  is null or
City is null or
Hour_num is null ;

-- find Duplicates --
select count(*) as count, Order_ID 
from sales 
group by 2 
having count > 1;


-- Step 3: Exploratory Data Analysis (EDA) 

-- Time analysis -- 
-- Top 10 days--
SELECT DATE(order_date) AS "Day", round(SUM(sales),2) AS total_sales
FROM sales
GROUP BY 1
ORDER BY 1 desc
limit 10;

-- Sales by day parts -- 
select case 
when Hour_num between 0 and 5 then "Midnight : Daybreak"
when Hour_num between 6 and 11 then "Morning"
when Hour_num between 12 and 17 then "Afternoon"
else "Night"
end As Day_parts,
 round(sum(sales),0) as Total_sales
from sales
group by 1 
order by 2 desc ;

-- sales by month -- 
select  month(convert(Order_Date,datetime)) as "Month" ,round(sum(Sales),2) Total_sales 
from sales 
group by 1
order by 1 ;
-- year qurter sales -- 
select year(convert(Order_Date,datetime)) As "Year",case 
when month(convert(Order_Date,datetime)) between 1 and 3 then "Q-1"
when month(convert(Order_Date,datetime)) between 4 and 6 then "Q-2"
when month(convert(Order_Date,datetime)) between 7 and 9 then "Q-3"
else "Q-4"
end As 'year_quarters',
 round(sum(sales),0) as Total_sales
from sales
group by 1,2 
order by 3 desc ;

-- year sales -- 
select  year(convert(Order_Date,datetime)) as "year" ,round(sum(Sales),2) Total_sales 
from sales 
group by 1
order by 1 ;


-- Top selling items and Revenue  -- 
select product , sum(Quantity_Ordered)  as Total_qty_ordered , Price_Each  Unit_Price, round(sum(Quantity_Ordered) * Price_Each,0) as Total_product_Rev
from sales 
group by 1 
order by 2 desc;

-- Geo Analysis -- 
select City ,round(sum(Sales),2) Total_sales
from sales
group by 1 
order by 2 desc ;

select City, product ,sum(Quantity_Ordered) Total_Qty_ordered
from sales 
group by 2
order by 3; 

-- Step 4 : Calculated Key Metrics and KPIs -- 

-- Total Revenue -- 

select round(sum(Sales),2) Total_sales 
from sales ; 

-- Monthly revenue groWth -- 

select Month_num As " Month", round(sum(sales),2) As "Total Revenu" , IFNULL(round(((SUM(sales) - LAG(SUM(sales)) OVER (ORDER BY Month_num)) / LAG(SUM(sales)) OVER (ORDER BY Month_num)*100),1),0) AS monthly_growth_percentage
from sales
group by 1 
order by 1;


-- calculate the quarterly growth --

WITH quarterly_sales AS (
    SELECT 
        CASE 
            WHEN month_num BETWEEN 1 AND 3 THEN 'Q1'
            WHEN month_num BETWEEN 4 AND 6 THEN 'Q2'
            WHEN month_num BETWEEN 7 AND 9 THEN 'Q3'
            ELSE 'Q4'
        END AS quarter,
        YEAR(order_date) AS year,
        SUM(sales) AS total_sales
    FROM sales
    GROUP BY 
        CASE 
            WHEN month_num BETWEEN 1 AND 3 THEN 'Q1'
            WHEN month_num BETWEEN 4 AND 6 THEN 'Q2'
            WHEN month_num BETWEEN 7 AND 9 THEN 'Q3'
            ELSE 'Q4'
        END,
        YEAR(order_date)
),
quarterly_growth AS (
    SELECT 
        year,
        quarter,
        total_sales,
        LAG(total_sales) OVER (ORDER BY year, quarter) AS previous_sales,
        (total_sales - LAG(total_sales) OVER (ORDER BY year, quarter)) / LAG(total_sales) OVER (ORDER BY year, quarter) * 100 AS growth_percentage
    FROM 
        quarterly_sales
)
SELECT 
    year,
    quarter,
    total_sales,
    previous_sales,
    COALESCE(growth_percentage, 0) AS growth_percentage
FROM 
    quarterly_growth
ORDER BY 
    year, quarter;

-- prodcut performance overview --

select round(avg(Price_Each),0)  AOV  ,max(Price_Each) MOV , min(Price_Each) MinOV 
from sales ;  

-- Above average price products performance --
select Product Above_average_price_products ,  Price_Each,sum(Quantity_Ordered)  as Total_qty_ordered
from sales 
where Price_Each > (select avg(Price_Each) from sales) 
and   Price_Each <= (select max(Price_Each)from sales)
group by 1
order by 2  ;

-- Below average price products performance --

select Product  Below_price_Avg_product,  Price_Each ,sum(Quantity_Ordered)  as Total_qty_ordered
from sales 
where Price_Each < (select avg(Price_Each) from sales) 
and   Price_Each >= (select min(Price_Each)from sales)
group by 1
order by 2 ;





























