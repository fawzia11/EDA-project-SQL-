/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables.

Table Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the database
select*
from gold.dim_customers;

select*
from gold.dim_products;

select*
from gold.fact_sales

-- Retrieve all columns for a specific table (dim_customers)
select*
from gold.dim_customers



/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- Retrieve a list of unique countries from which customers originate
select
distinct country
from gold.dim_customers

-- Retrieve a list of unique categories, subcategories, and products

select 
distinct 
 category,
 product_name,
 subcategory
from gold.dim_products
order by category asc

------or----
select distinct category from gold.dim_products;

select distinct product_name from gold.dim_products;

select distinct subcategory from gold.dim_products;



/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
select
max(order_date) as [last order],
min(order_date) as [first order],
DATEDIFF(month,min(order_date) , max(order_date))  as [total duration]
from gold.fact_sales

-- Find the youngest and oldest customer based on birthdate

select
max(birthdate) as [oldest customer],
min(birthdate) as [yungest custome]
from gold.dim_customers

/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Find the Total Sales
select
sum(sales_amount)
from gold.fact_sales

-- Find how many items are sold
select
sum(quantity) 
from gold.fact_sales

-- Find the average selling price
select
avg(coalesce(price , 0))
from gold.fact_sales

-- Find the Total number of Orders
select 
count ( distinct order_number)
from gold.fact_sales

-- Find the total number of products
select
count ( product_key)
from gold.dim_products

-- Find the total number of customers
select 
count ( customer_key)
from gold.dim_customers

-- Find the total number of customers that has placed an order
select
count ( customer_id ),
count (distinct customer_id)
from gold.dim_customers as c
inner join gold.fact_sales as s 
on s.customer_key = c.customer_key
----مش عارفه اسيب العملاء المتكررين ولا لا ولا انا فاهمه حاجه غلط ؟


-- Generate a Report that shows all key metrics of the business
-- مش ده اللي كنت بحسب زيه فوق 


/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding data distribution across categories.

SQL Functions Used:
    - Aggregate Functions: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
===============================================================================
*/

-- Find total customers by countries
select 
	country,
	sum(customer_key) as [ total customers]
from gold.dim_customers
group by country
order by country asc

-- Find total customers by gender
select 
	gender,
	sum(customer_key) as [ total customers]
from gold.dim_customers
group by gender

-- Find total products by category
select
category,
count(product_name) [ total products]
from gold.dim_products
group by category
-- What is the average costs in each category?
select
category,
avg(coalesce (cost , 0)) as [ avg..cost ],
avg(cost) as [avg. with nulls]
from gold.dim_products
group by category

-- What is the total revenue generated for each category?

select
category,
sum(sales_amount) as [ total revenue]
from gold.fact_sales as s
inner join gold.dim_products as p
on s.product_key = p.product_key
group by category

-- What is the total revenue generated by each customer?
select
s.customer_key,
concat(c.first_name,' ',c.last_name) as [full name ],
sum(sales_amount) as [ total revenue]
from gold.dim_customers as c
inner join gold.fact_sales as s 
on s.customer_key = c.customer_key
group by s.customer_key , concat(c.first_name,' ',c.last_name)
 

-- What is the distribution of sold items across countries?
select
country,
count(product_key) as [ sold items]
from gold.dim_customers as c
inner join gold.fact_sales as s 
on s.customer_key = c.customer_key
group by country

/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Ranking Functions: TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
select
	top (5)
	product_name,
	sum(sales_amount)  as [total sales]
from gold.dim_products as p
inner join gold.fact_sales as s
on p.product_id = s.product_key
group by product_name
order by [total sales] desc

-- What are the 5 worst-performing products in terms of sales?
select
	top (5)
	product_name,
	sum(sales_amount)  as [total sales]
from gold.dim_products as p
inner join gold.fact_sales as s
on p.product_id = s.product_key
group by product_name
order by [total sales] asc
-- Find the top 10 customers who have generated the highest revenue

	select 
		top (10)
		c.customer_key,
		concat(c.first_name,' ',c.last_name) as [full name ],
		sum(sales_amount) as [total revenue ]
	from gold.dim_customers as c
	inner join gold.fact_sales as s
	on s.customer_key = c.customer_key
	group by c.customer_key , concat(c.first_name,' ',c.last_name)
	order by sum(sales_amount) desc

-- The 3 customers with the fewest orders placed


select top (3)*
from(
	select 
	c.customer_key,
	concat(c.first_name,' ',c.last_name) as [full name ],
	count(distinct order_number) as [total orders]
	from gold.dim_customers as c
	inner join gold.fact_sales as s
	on s.customer_key = c.customer_key
	group by c.customer_key , concat(c.first_name,' ',c.last_name)
	) as sub
	order by sub.[total orders] asc