--- creating database

create database Project

--- creating table

create table Toy_sale
(Sale_ID varchar(max),	Date varchar(max),	Store_ID varchar(max),	Product_ID varchar(max),	Units varchar(max))


create table Toy_store
(Store_ID varchar(max),	Store_Name varchar(max), Store_City varchar(max), 
Store_Location varchar(max), Store_Open_Date varchar(max))


create table Toy_product
(Product_ID	varchar(max), Product_Name	varchar(max), Product_Category	varchar(max), 
Product_Cost	varchar(max), Product_Price varchar(max))


create table Toy_inventory
(Store_ID varchar(max),	Product_ID	varchar(max), Stock_On_Hand varchar(max))

select * from Toy_sale

select * from Toy_store

select * from Toy_product

select * from Toy_inventory


---loading values using bulk insert

bulk insert Toy_sale
from 'C:\Users\nayan\Downloads\sales.csv'
with (fieldterminator=',', rowterminator='\n', firstrow=2, maxerrors=20)


bulk insert Toy_store
from 'C:\Users\nayan\Downloads\stores.csv'
with (fieldterminator=',', rowterminator='\n', firstrow=2, maxerrors=20)


bulk insert Toy_Product
from 'C:\Users\nayan\Downloads\products.csv'
with (fieldterminator=',', rowterminator='\n', firstrow=2, maxerrors=20)


bulk insert Toy_Inventory
from 'C:\Users\nayan\Downloads\inventory.csv'
with (fieldterminator=',', rowterminator='\n', firstrow=2, maxerrors=20)


use Project
---checking data type

select column_name, data_type
from information_Schema.columns

--- need to convert data type
--Sales
/*Sale_ID	varchar
Date	date
Store_ID	int
Product_ID	int
Units	int

--Stores
Store_ID	int
Store_Name	varchar
Store_City	varchar
Store_Location	varchar
Store_Open_Date	varchar

--products
Product_ID	int
Product_Name	varchar
Product_Category	varchar
Product_Cost	decimal
Product_Price	decimal

--Inventory
Store_id	int
Product_id	int
stock_on_hand	int */

--- let's check the data consistency

create index fordatcheck on Toy_sale(sale_id)

select * from Toy_sale
where isnumeric(sale_id)=0

--- there is no non numeric value

select * from Toy_sale
where isnumeric(store_id)=0

--- there is no non numeric value

select * from Toy_sale
where isnumeric(product_id)=0

--- there is no non numeric value

select * from Toy_sale
where isnumeric(units)=0

--- there is no non numeric value


select * from Toy_sale
where isdate([date])=0


select date, try_convert(date,[date],103) from Toy_sale
where try_convert(date,[date],103) is not null

update Toy_sale set [date]=try_convert(date,[date],103)
where try_convert(date,[date],103) is not null

select [date], case when 

select [date] from Toy_sale
where isdate([date])=0

--  changing the dtype of date 
alter table Toy_sale
alter column date date

alter table Toy_sale
alter column product_id int


alter table Toy_sale
alter column sale_id int


alter table Toy_sale
alter column units int

alter table Toy_sale
alter column store_id int

select * from Toy_sale


--- Products

select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where table_name=' Toy_Product'

alter table  Toy_product
alter column product_id int

alter table  Toy_product
alter column product_cost decimal(5,2)

select product_price from  Toy_product

update  Toy_product set product_cost=replace(product_cost,'$','')

alter table  Toy_product
alter column product_price decimal(7,2)

update  Toy_product set product_price=replace(product_price,'$','')


alter table  Toy_product
alter column product_id int

select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where table_name in(' Toy_Inventory',' Toy_store')

--- store
alter table Toy_store
alter column store_open_date date


select * from Toy_store
where isdate(store_open_date) =0

select store_open_date, try_convert(date,store_open_date,103) from Toy_store


Update Toy_store set store_open_date=try_convert(date,store_open_date,103) 

alter table Toy_store
alter column store_open_date date

---inventory
alter table  Toy_Inventory
alter column stock_on_hand int


select Column_name, Data_type 
from INFORMATION_SCHEMA.columns
where table_name in(' Toy_Inventory',' Toy_store',' Toy_sale',' Toy_product')

select count(distinct sale_id) from Toy_sale

select count(Distinct product_id) from Toy_product

select * from Toy_sale
select * from Toy_product
select * from Toy_inventory
select * from Toy_store


--- Checking for duplicates and remove them 

with Duplrows as(select *, row_number() over(partition by Product_id,Product_name,Product_category,Product_cost,Product_price order by product_id) as row_num
from Toy_product
)

select * from Duplrows
where row_num>1

----ANALYSIS

---Identify top-performing products based on total sales and profit
use Project

select* from Toy_product
select top 5 P.product_id, P.Product_name, sum(S.units) as 'Total_units_sold',
sum(S.units *Product_price) as revenue, Sum(S.units * (product_price-product_cost)) as 'Profit'
from Toy_product P
join Toy_sale s
on p.product_id=s.product_id
group by p.product_id,P.product_name
order by profit desc


----Analyse sales performance for each store, including total revenue and profit margin.
select * from Toy_sale


select s.store_id, s.Date, st.store_name, sum(s.units) as 'Total_units_sold',
sum(s.units*p.product_price) as 'total_rev',
SUM(s.units * (product_price-product_cost)) as 'profit'
from Toy_sale s
join Toy_store st
on s.store_id=st.store_id
join Toy_product p
on s.product_id=p.product_id
group by s.store_id, s.Date, st.store_name
order by profit desc

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name= 'Toy_product'

select * from Toy_product
where Product_Cost


---Examine monthly sales trends, considering the rolling 3-month average and identifying months with significant growth or decline

select min(date), max(date) from Toy_sale

With Sales_trnd As (select datename(month,date) as 'sales_month',
		sum(case when year(date)=2022 then units else 0 end) as 'sales_of_2022',
		sum(case when year(date)=2023 then units else 0 End) as 'Sales_of_2023',
		(sum(case when year(date)=2023 then units else 0 end)-
		sum(case when year(date)=2022 then units else 0 End)) as 'diff_in_sales'
		from Toy_sale
group by  datename(month,date))

Select *,round(cast((100.0* diff_in_sales/sales_of_2022) as float),2) as 'Perc_diff_in_sales'
, case when diff_in_sales<0 then 'Decline_in_sales'
		when diff_in_sales>0 then 'growth_in_sales'
		else ''
		end as 'sales_trend'
		 from sales_trnd



---Calculate the cumulative distribution of profit margin for each product category, consider where products are having profit.

 select* from Toy_product
select  P.product_id, P.Product_category, 
sum(S.units *Product_price) as revenue, Sum(S.units * (product_price-product_cost)) as 'Profit'
from Toy_product P
join Toy_sale s
on p.product_id=s.product_id
group by p.product_id,P.product_category
order by profit desc

---Analyze the efficiency of inventory turnover for each store by calculating the Inventory Turnover Ratio.
 use final_project
 

	with Comp_sales as(select p.product_category, year(s.date) as 'Year/s', datepart(quarter,s.date) as 'Quarterlys', 
sum(s.units) as 'total_un_sold'
from Toy_sale s
join Toy_product P
on s.product_id=p.product_id
group by p.product_category, datepart(quarter,s.date), year(s.date))
, 

---Prev_year_sales=2022
Prev_sales  as (select product_category,Quarterlys, total_un_sold as 'Prev_yr_unitsold'
from comp_sales 
where [year/s]=2022),

---current_year_Sales-2023
 current_yr_sales as( select product_category,Quarterlys, total_un_sold as 'Crrnt_yr_unitsold'
from comp_sales 
where [year/s]=2023)

select c.product_category,c.Quarterlys,p.prev_yr_unitsold,crrnt_yr_unitsold, (crrnt_yr_unitsold-p.prev_yr_unitsold) as 'Diff'
from current_yr_Sales c
join prev_sales p
on c.product_category=p.product_category
 and c.quarterlys=p.quarterlys

 with sales_category as ( select p.product_category,
        SUM(case when year (s.date)=2022 then s.units*p.product_cost else 0 end) as COGS_2022
		,SUM(case when year (s.date)=2022 then s.units*p.product_cost else 0 end) as COGS_2023
		from Toy_sale s
		join Toy_product p
		on s.product_id=p.product_id
		group by p.product_category)


,avg_inventory as (select p.product_category,avg(case when year(s.date)=2022 then i.stock_on_hand else 0 end) as Avg_inventory_2022
       ,avg(case when year(s.date)=2023 then i.stock_on_hand else 0 end) as Avg_inventory_2023
	   from Toy_inventory i
	   join Toy_product P
	   on i.product_id=p.product_id
	   join Toy_sale S
	   on i.product_id=s.Product_ID
	   group by p.Product_Category)

,Inv_goods_sold as (select sc.product_category, sc.COGS_2022, ai.Avg_inventory_2022, sc.COGS_2023,ai.Avg_inventory_2023
from sales_category sc
join avg_inventory Ai
on sc.product_category=ai.product_category)

select Product_category,COGS_2022,avg_inventory_2022,(COGS_2022/avg_inventory_2022) as inv_turn_ratio_2022,cogs_2023, avg_inventory_2023,
(COGS_2023/avg_inventory_2023) as inv_turn_ratio_2023
from Inv_goods_sold