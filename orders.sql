SELECT product_id, SUM(sales_price) AS sales
FROM df1
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

-- find top 5 highest selling products in each region
with cte as (
select region,product_id,sum(sales_price) as sales
from df1
group by region,product_id)
select * from (
select *
, row_number() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5


-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sales_price) AS sales
    FROM df1
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT 
    order_month,
    MAX(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    MAX(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- for each category which month had highest sales 
with cte as (
select category,format(order_date,'yyyyMM') as order_year_month
, sum(sales_price) as sales 
from df1
group by category,format(order_date,'yyyyMM')
-- order by category,format(order_date,'yyyyMM')
)
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


with cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM df_orders
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY sub_category, YEAR(order_date)
),


-- which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT 
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(sales_price) AS sales
    FROM df1
    WHERE YEAR(order_date) IN (2022, 2023)
    GROUP BY sub_category, YEAR(order_date)
),

-- order by year(order_date),month(order_date)
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
        SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte 
    GROUP BY sub_category
)
SELECT 
    sub_category,
    sales_2022,
    sales_2023,
    (sales_2023 - sales_2022) AS sales_growth
FROM cte2
ORDER BY sales_growth DESC
LIMIT 1;

