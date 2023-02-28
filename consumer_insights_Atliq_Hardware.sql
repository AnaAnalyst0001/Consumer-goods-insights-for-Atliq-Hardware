
-- 1 list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
select distinct market, customer, region from gdb023.dim_customer where customer="Atliq Exclusive" and region="APAC";

-- 2 The percentage increase in unique product in 2021 vs. 2020
WITH cte_2020 as (
select count(distinct product_code) as unique_products_2020 from gdb023.fact_sales_monthly where fiscal_year="2020"
),
cte_2021 as (
select count(distinct product_code) as unique_products_2021, ((334-245)/245)*100 as percentage_chg from gdb023.fact_sales_monthly where fiscal_year="2021" 
)
SELECT * FROM cte_2020, cte_2021;

-- 3 Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.

SELECT count(product_code) as product_count, segment FROM gdb023.dim_product group by segment order by product_count desc;


-- 4 Which segment had the most increase in unique products in 2021 vs 2020?

with x as (select count(distinct dim_product.product_code) as pc_2020, segment from dim_product join fact_sales_monthly 
on dim_product.product_code=fact_sales_monthly.product_code where fiscal_year="2020" group by segment),
y as (select count(distinct dim_product.product_code) as pc_2021, segment from dim_product join fact_sales_monthly 
on dim_product.product_code=fact_sales_monthly.product_code where fiscal_year="2021" group by segment)
select x.segment, pc_2020, pc_2021, (pc_2021-pc_2020) as difference from x join y where x.segment=y.segment;

-- 5 Get the products that have the highest and lowest manufacturing costs

select * from gdb023.fact_manufacturing_cost;
select * from gdb023.dim_product;
select dim_product.product_code, product, manufacturing_cost from gdb023.dim_product join gdb023.fact_manufacturing_cost 
on dim_product.product_code=fact_manufacturing_cost.product_code order by manufacturing_cost DESC;

-- 6 Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
-- to calculate the average of pre-invoice discount percentage
select avg(pre_invoice_discount_pct) from gdb023.fact_pre_invoice_deductions;

-- Next, we want to check the top 5 customers (dim_customer table) with pre-invoice discount percentage 
 -- as high as avg(pre-invoice discount percentage) calculated above
 select dim_customer.customer_code, customer, pre_invoice_discount_pct, fiscal_year, market from gdb023.dim_customer
 join gdb023.fact_pre_invoice_deductions on dim_customer.customer_code=fact_pre_invoice_deductions.customer_code
 where fiscal_year="2021" AND pre_invoice_discount_pct<=0.24 AND market="India" order by pre_invoice_discount_pct desc limit 5;
 
-- 7 Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month 
select MONTH(date), YEAR(date), (fsm.sold_quantity*fgp.gross_price) as Gross_sales_amt FROM gdb023.fact_gross_price as fgp 
left join gdb023.fact_sales_monthly as fsm on fgp.product_code=fsm.product_code
left join gdb023.dim_customer as dc on fsm.customer_code=dc.customer_code WHERE customer="Atliq Exclusive";

-- 8 In which quarter of 2020, got the maximum total_sold_quantity?
select product_code, date, QUARTER(date), YEAR(date), sold_quantity from gdb023.fact_sales_monthly WHERE YEAR(date)="2020" 
order by sold_quantity desc;

with cte_new as (
 select product_code, date, QUARTER(date), YEAR(date), sold_quantity from gdb023.fact_sales_monthly WHERE YEAR(date)="2020" 
order by sold_quantity desc
)
select sum(sold_quantity) as tot_sold_qty, QUARTER(date) from cte_new WHERE YEAR(date)="2020" group by QUARTER(date) order by tot_sold_qty desc;


-- 9 Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
select dc.channel, (fsm.sold_quantity*fgp.gross_price) as gross_sales_mln FROM gdb023.fact_gross_price as fgp 
left join gdb023.fact_sales_monthly as fsm on fgp.product_code=fsm.product_code
left join gdb023.dim_customer as dc on fsm.customer_code=dc.customer_code WHERE fgp.fiscal_year="2021";

with cte_x as (
select dc.channel, (fsm.sold_quantity*fgp.gross_price) as gross_sales_mln FROM gdb023.fact_gross_price as fgp 
left join gdb023.fact_sales_monthly as fsm on fgp.product_code=fsm.product_code
left join gdb023.dim_customer as dc on fsm.customer_code=dc.customer_code WHERE fgp.fiscal_year="2021"
)
select sum(gross_sales_mln), channel, ((sum(gross_sales_mln)/2212376280.432)*100) as percentage from cte_x group by channel;

-- 10 Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?

-- N&S
select product, dp.product_code, division, sold_quantity, dense_rank() OVER (partition by division order by sold_quantity desc) AS ranking
 from gdb023.dim_product as dp join gdb023.fact_sales_monthly 
 as fsm on dp.product_code=fsm.product_code where fiscal_year="2021" and division="N & S";
 
 -- P&A
 select product, dp.product_code, division, sold_quantity, dense_rank() OVER (partition by division order by sold_quantity desc) AS ranking
 from gdb023.dim_product as dp join gdb023.fact_sales_monthly 
 as fsm on dp.product_code=fsm.product_code where fiscal_year="2021" and division="P & A";
 -- PC
  select distinct product, dp.product_code, division, sold_quantity, dense_rank() OVER (partition by division order by sold_quantity desc) AS ranking
 from gdb023.dim_product as dp join gdb023.fact_sales_monthly 
 as fsm on dp.product_code=fsm.product_code where fiscal_year="2021" and division="PC";
 