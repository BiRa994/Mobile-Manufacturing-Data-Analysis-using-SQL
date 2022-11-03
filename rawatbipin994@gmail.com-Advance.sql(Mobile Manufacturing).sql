--SQL Advance Case Study

Select * from DIM_customer
Select * from Dim_Date
Select * from DIM_location
Select * from Dim_Manufacturer
SElect * from DIM_Model
Select * from FACT_Transactions


--Q1. List all the states in which we have customers who have bought cellphones from 2005 till today. 
 
--Q1--BEGIN 

select Customer_Name, state, Date  
from DIM_LOCATION l inner join FACT_TRANSACTIONS f on l.IDLocation = f.IDLocation
inner join DIM_CUSTOMER c on c.IDCustomer = f.IDCustomer 
where Date between '2005-01-01' and getdate()

--Q1--END


--Q2. What state in the US is buying the most 'Samsung' cell phones? 

--Q2--BEGIN

Select top 1 state, Manufacturer_Name,sum(Quantity)[count of Samsung phones]
from DIM_Location l inner join FACT_Transactions f on l.IDLocation = f.IDLocation 
inner join DIM_Model mo on f.IDModel = mo.IDModel inner join DIM_MANUFACTURER ma on ma.IDManufacturer = mo.IDManufacturer
where Manufacturer_Name ='Samsung' and country = 'US'
group by Manufacturer_Name,State
order by [count of Samsung phones] desc

--Q2--END



--Q3. Show the number of transactions for each model per zip code per state. 

--Q3--BEGIN      

Select Model_Name, ZipCode, State, count(IDCustomer)[Transactionss for each Models] 
from DIM_LOCATION l inner join FACT_TRANSACTIONS f on l.IDLocation = f.IDLocation 
inner join DIM_MODEL mo on mo.IDModel = f.IDModel
group by Model_Name,ZipCode , State
 
--Q3--END



--Q4. Show the cheapest cellphone (Output should contain the price also)

--Q4--BEGIN

select  top 1 Manufacturer_Name, Model_Name,mo.IDModel, TotalPrice
from DIM_MODEL mo inner join FACT_Transactions  f on mo.IDModel = f.IDModel inner join DIM_MANUFACTURER ma
on mo.IDManufacturer =ma.IDManufacturer
order by TotalPrice

--Q4--END



--Q5.Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.  

--Q5--BEGIN

select  Manufacturer_Name, Model_Name, avg(Unit_price)[Average Model Price],sum(Quantity)[Quantity]
from DIM_MODEL mo inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer 
inner join FACT_TRANSACTIONS f on mo.IDModel = f.IDModel
Where Manufacturer_Name in 
(Select top 5 Manufacturer_Name
from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer = mo.IDManufacturer 
inner join FACT_TRANSACTIONS f on f.IDModel = mo.IDModel
group by Manufacturer_Name
order by sum(Quantity) )
group by Manufacturer_Name, Model_Name
order by [Average Model Price] desc

--Q5--END




--Q6. List the names of the customers and the average amount spent in 2009, where the average is higher than 500.

--Q6--BEGIN

Select Customer_Name, avg(TotalPrice)[Average Price] from DIM_CUSTOMER c inner join FACT_TRANSACTIONS f on c.IDCustomer = f.IDCustomer
where year(Date)='2009'
group by Customer_Name 
having avg(TotalPrice) > 500

--Q6--END
	



--Q7. List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010.

--Q7--BEGIN  

  select * from
             (select * from
             (Select top 5 Model_Name from DIM_MODEL mo inner Join FACT_TRANSACTIONS f on mo.IDModel=f.IDModel 
               Where year(Date)='2008' 
                group by Model_Name
                order by Sum(Quantity) desc) X

                 Intersect

               select * from
               (Select top 5 Model_Name from DIM_MODEL mo inner Join  FACT_TRANSACTIONS f on mo.IDModel = f.IDModel
                 Where year(Date)='2009' 
                  group by Model_Name
                 order by Sum(Quantity) desc) Y

                   Intersect

                select * from
                (Select top 5 Model_Name from  DIM_MODEL mo inner Join FACT_TRANSACTIONS f on mo.IDModel = f.IDModel 
				  where year(Date)='2010'
                 group by Model_Name
                 order by Sum(Quantity) desc) Z
                  ) as TT
                  Group by Model_Name
                  Having count(Model_Name)=3


--Q7--END	



--Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

--Q8--BEGIN 

Select * From
            (Select * from
            (Select  top 2 Manufacturer_Name, sum(TotalPrice)[sales],year(Date)[Year]
            from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer = mo.IDManufacturer 
            inner join FACT_TRANSACTIONS f on f.IDModel = mo.IDModel
             where year(Date) ='2009' 
             group by Manufacturer_Name,Year(Date)
             order by [sales] Desc) X

             Union 

            Select * from
             (Select  top 2 Manufacturer_Name, sum(TotalPrice)[sales],Year(Date)[Year]
              from DIM_MANUFACTURER ma inner join DIM_MODEL mo on ma.IDManufacturer = mo.IDManufacturer 
                 inner join FACT_TRANSACTIONS f on f.IDModel = mo.IDModel
             where year(Date) ='2010' 
                group by Manufacturer_Name,Year(Date)
             order by [sales] Desc)Y
               ) XY

--Q8--END



--Q9.  Show the manufacturers that sold cellphones in 2010 but did not in 2009. 

--Q9--BEGIN 

	Select Manufacturer_Name
	from DIM_MANUFACTURER ma inner join DIM_MODEL mo on mo.IDManufacturer = ma.IDManufacturer 
	inner join FACT_TRANSACTIONS f on f.IDModel = mo.IDModel
	where year(Date)='2010' 
	and Manufacturer_Name not in 
	(Select Manufacturer_Name
	from DIM_MANUFACTURER ma inner join DIM_MODEL mo on mo.IDManufacturer = ma.IDManufacturer 
	inner join FACT_TRANSACTIONS f on f.IDModel = mo.IDModel
	where year(Date)='2009'
	group by Manufacturer_Name)
	group by Manufacturer_Name

--Q9--END



--Q10. Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

--Q10--BEGIN

Select top 100 Customer_Name, year(Date)[Year], avg(TotalPrice)[Average Spend],avg(Quantity)[Average Qty.],
sum(TotalPrice)/lag(sum(TotalPrice),1) over(order by year(Date)) [Change in Spend]
from DIM_CUSTOMER c inner join FACT_TRANSACTIONS f on c.IDCustomer = f.IDCustomer
group by Customer_Name,Year(Date)
order by [Average Spend] desc ,[Average Qty.] desc


--Q10--END
	