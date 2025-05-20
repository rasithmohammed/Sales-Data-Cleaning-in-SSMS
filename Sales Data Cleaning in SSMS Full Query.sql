Select * From sales
---------------------------------------------------------
--Step 1 :- To check for duplicates
--Step 2 :- Check For Null Values
--Step 3 :- Treating Null values
--Step 4 :- Handling Negative values
--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates
--Step 6 :- Fixing Invalid Email Addresses
--Step 7 :- Checking the datatype
--------------------------------------------------------------------------------------------
--Step 1 :- To check for duplicates

With cte as(
select *,
      ROW_NUMBER() over(partition by transaction_id order by transaction_id) row_num
from sales
)
--delete from cte
--where row_num >1
select* 
from cte 
where transaction_id in(1001,1004,1030,1074)
-------------------------------------------------------------------------------------------------------

--Step 2 :- Check For Null Values

select * from sales	  
where transaction_id is null

--or

DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @tableName NVARCHAR(128) = 'sales';  -- Replace with your table name

-- Build dynamic SQL to count NULLs in each column
SELECT @sql = STRING_AGG(
    'SUM(CASE WHEN [' + COLUMN_NAME + '] IS NULL THEN 1 ELSE 0 END) AS [' + COLUMN_NAME + '_nulls]',
    ', ' + CHAR(13) + CHAR(10)
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName;

-- Add SELECT and FROM
SET @sql = 'SELECT ' + CHAR(13) + CHAR(10) + @sql + CHAR(13) + CHAR(10) + 'FROM ' + QUOTENAME(@tableName) + ';';

-- Print or execute
PRINT @sql;
EXEC sp_executesql @sql;
-------------------------------------------------------------------------------------------------------------------------
--Step 3 :- Treating Null values
select distinct category from sales
----------------------Category
update sales
set category ='Unkown'
where category is null
-----------------------customer_address_nulls
update sales
set customer_address ='Not Availabel'
where customer_address is null
-----------------------payment_method
select distinct payment_method from sales
update sales
set payment_method ='Credit Card'
where payment_method in ('creditcard','CC','credit' )

update sales
set payment_method ='Cash'
where payment_method is null
-----------------------Delivery_status
select distinct delivery_status from sales
update sales
set delivery_status ='Not Delivered'
where delivery_status is null

-----------------------Total_Amount
select distinct total_amount from sales
update sales
set delivery_status ='Not Delivered'
where delivery_status is null

-----------------------Price
--- MEAN(AVG)---2510.76804057412
SELECT AVG(price) from sales

---MODE
select price, count(*) as max_count
from sales
group by price
order by max_count desc;
---MEDIAN---2530.75
select distinct 
  percentile_cont(0.5) within group (order by price) over() as median
  from sales
------------------------------------------------------

select category, avg(price) as avg_price
from sales
group by category
------------------------------------------------------
--Clothing                 
--Toys
--Unkown
--Electronics
--Books
--Home & Kitchen
--2539.27819389209
--2235.47169659589
--2511.41641440423
--2663.9278355295
--2574.45734735087
--2507.05837494618
------- Unkown 
update sales 
set price = 2511.41
where price is null and category ='Unkown'

--Home & Kitchen
update sales 
set price = 2507.05
where price is null and category ='Home & Kitchen'
--Toys
update sales 
set price = 2235.47
where price is null and category ='Toys'
--Electronics
update sales 
set price = 2663.92
where price is null and category ='Electronics'

--Clothing
update sales 
set price = 2539.27
where price is null and category ='Clothing'
--Books
update sales 
set price = 2574.45
where price is null and category ='Books'
------------------------------------------------------------------------------------
--Step 4 :- Handling Negative values
select * from sales
where quantity <0

update sales
set quantity = abs(quantity)
where quantity <0;

update sales
set total_amount= price*quantity
where total_amount is null or total_amount <> price*quantity

select * from sales
where customer_id is null

update sales 
set customer_name ='User'
where customer_name is null
-------------------------------------------------------------------

--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates

select * from sales
where purchase_date= '30-02-2024'

update sales
set purchase_date= 
          case
		      when TRY_CONVERT(date,purchase_date, 103) is not null
		      then TRY_CONVERT(date, purchase_date,103)
		  else null
end;
-------------------------------------------------------------------
--Step 6 :- Fixing Invalid Email Addresses

select * from sales 
where email not like '%@%'

ALTER TABLE sales
ALTER COLUMN email VARCHAR(255) NULL;

update sales
set email = NULL
where email not like '%@%'
-------------------------------------------------------------------------------
--Step 7 :- Checking the datatype

SELECT purchase_date
FROM sales
WHERE ISDATE(purchase_date) = 0;

DELETE FROM sales
WHERE ISDATE(purchase_date) = 0;

UPDATE sales
SET purchase_date = NULL
WHERE ISDATE(purchase_date) = 0;

ALTER TABLE sales
ALTER COLUMN purchase_date DATE;

