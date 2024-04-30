#1
SELECT distinct market
FROM dim_customer
where customer= "Atliq Exclusive"and region= "APAC";

#2
with cte1 as (select
 (select count(distinct product_code) from fact_sales_monthly where fiscal_year=2020 ) as unique_products2020,
(select count(distinct product_code) from fact_sales_monthly where fiscal_year=2021) as unique_products2021)
select *, (unique_products2021-unique_products2020)*100/unique_products2020 as percentage_chg
from cte1;




#3
select segment,count(distinct product_code) as product_count
from dim_product
group by segment
order by product_count desc;

#4
with cte1 as(
select p.segment as P,count(distinct s.product_code) as A
from dim_product p
join fact_sales_monthly s on p.product_code=s.product_code
group by p.segment,s.fiscal_year
having fiscal_year=2020),

cte2 as(
select p.segment as R,count(distinct s.product_code) as B
from dim_product p
join fact_sales_monthly s on p.product_code=s.product_code
group by p.segment,s.fiscal_year
having fiscal_year=2021)

 select cte1.P as segment,
 cte1.A as product_count2020,
 cte2.B as product_count2021,
 cte2.B-cte1.A as difference
 from cte1,cte2
 where cte1.P=cte2.R;
 
#5
select mc.product_code,p.product,mc.manufacturing_cost
from fact_manufacturing_cost mc
join dim_product p
on mc.product_code=p.product_code
where manufacturing_cost in
(select min(manufacturing_cost) from fact_manufacturing_cost union
select max(manufacturing_cost)from fact_manufacturing_cost)
group by product
order by manufacturing_cost desc;

#6
SELECT pre.customer_code,c.customer, avg(pre.pre_invoice_discount_pct) as avg_discount_pct
FROM fact_pre_invoice_deductions pre
join dim_customer c on pre.customer_code=c.customer_code
where market="India" and fiscal_year=2021
group by customer_code
order by avg_discount_pct desc
limit 5;


#7 
with cte1 as (SELECT c.customer,
monthname(s.date) as Month_name,
month(s.date) as Month,
year(s.date) as year, 
s.sold_quantity,g.gross_price,  (sold_quantity*gross_price) as Gross_sales_amount
FROM gdb023.fact_sales_monthly s
JOIN fact_gross_price g on s.product_code=g.product_code
JOIN dim_customer c on s.customer_code=c.customer_code
where customer= "Atliq Exclusive")

select Month_name,Month,year, Concat(round(sum(Gross_sales_amount)/1000000,2),"M") as Gross_sales_mil
from cte1
group by year,Month_name
order by year,month asc
;


#8
with cte1 as (
SELECT month(date) as month, sold_quantity
FROM 
fact_sales_monthly
where fiscal_year=2020
)

select
(case when  month in (9,10,11) then "Q1"
when month in (12,1,2) then "Q2"
when month in (3,4,5) then "Q3"
else "Q4" 
end) as quarter, (sum(sold_quantity)/1000000) as total_sold_quantitymil
from cte1
group by quarter
order by total_sold_quantitymil desc;


#9 
with cte1 as (
SELECT c.channel, sum(g.gross_price*s.sold_quantity) as total_sales
 FROM fact_sales_monthly s
 join fact_gross_price g on s.product_code=g.product_code
 join dim_customer c on s.customer_code=c.customer_code
 group by channel
 order by total_sales)
 select 
 channel,
round(total_sales/1000000,2) as total_sales_mln,
round(total_sales*100/sum(total_sales) over(),2)  as percentage
 from cte1;
 
 #10
 with cte1 as (
SELECT p.division,p.product_code,p.product,sum(s.sold_quantity) as total_sold_quantity,
dense_rank() over(partition by division order by sum(s.sold_quantity) desc) as rank_no
FROM fact_sales_monthly s 
 JOIN dim_product p on s.product_code=p.product_code
 group by division,product)
 
 select * from cte1
 where rank_no in (1,2,3)
 
 


 

