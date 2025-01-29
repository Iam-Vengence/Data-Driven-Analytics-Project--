use modelcarsdb;

-- task1
-- 1.find top10 customers from credit limit
select customerName,creditLimit from customers
order by 2
limit 10;
-- 2. find average credit limit of customers in each country
select state,avg(creditLimit) as avg_creditlimit from customers
group by state;
-- 3. find the number of customers in each state
select state,count(customerNumber) as total_customers from customers
group by 1;
-- 4.Find the customers who have not placed any order
select customerName from customers
where customerNumber not in (select customerNumber from orders);
-- 5.calculate total sales of each customer
select customerNumber,sum(orderdetails.quantityOrdered*priceEach) as total_sales from customers 
join orders using(customerNumber) 
join orderdetails using(orderNumber) join products using(productCode)
group by 1;
-- 6.List customers with there assigned sales representative
select customerName , (select firstName from employees where employees.employeeNumber = customers.salesRepEmployeeNumber ) as sales_representative from customers  ;
-- 7.Retrive customer information with most recent payement detalis
select  customers.*, payments.*
from customers join (select  customerNumber, max(paymentDate) as PaymentDate from payments
group by customerNumber
) as latestpayments on customers.customerNumber = latestpayments.customerNumber
join payments on latestpayments.customerNumber = payments.customerNumber and latestpayments.PaymentDate = payments.paymentDate;
-- 8. Identify customes who have exceed there credit limit
select customerNumber,creditLimit,sum(quantityOrdered*priceEach) as total_sales from customers join
 orders using(customerNumber)  join orderdetails using(orderNumber) 
group by customerNumber
having sum(orderdetails.quantityOrdered*priceEach) > creditLimit ;

-- 9.find all names of customers who have place an order for a product from a specfic product line
select distinct customerName,productLine from customers join orders using (customerNumber) join orderdetails using(orderNumber) join products using(productCode) 
join productlines using (productLine) where productLine = 'Classic Cars';
-- 10. find names of all customers who have placed oreder for most expensive product
select customerName ,MSRP from customers join orders using (customerNumber) join orderdetails using(orderNumber) join products using(productCode)  
where MSRP in(select max(MSRP) from products);


-- task2
-- 1.Count no of employees working in each office
select officeCode,count(employeeNumber) as total_employees from employees
group by 1;
-- 2.Identify the offices less than certain number of employees
select officeCode,count(employeeNumber) as total_employees from employees
group by 1
having total_employees < 3;
-- 3.List of offices along with assigned territories
select officeCode,territory from offices 
where territory != 'NA';
-- 4.Find offices that have no employees assinged to them
select  employeeNumber,officeCode from employees where officeCode = 'NUll';
-- 5. retrive most profitable office based on sales
select employees.officeCode,sum(orderdetails.quantityOrdered*priceEach) as totalsales from employees join
customers on employees.employeeNumber = customers.salesRepEmployeeNumber join orders
on customers.customerNumber = orders.customerNumber join orderdetails on orders.orderNumber = orderdetails.orderNumber
group by employees.officeCode
order by totalsales desc
limit 1;
-- 6. find office with highest number of employees
select officeCode,count(employeeNumber) as total_employees from employees
group by 1
order by  total_employees desc
limit 1;
-- 7.find the average creditlimit for customers in each office
select officeCode,avg(creditlimit) as averageCreditlimit from employees join customers on employees.employeeNumber = customers.salesRepEmployeeNumber
group by 1; 
-- 8. find number of offices in each country
select country,count(officeCode) as countryWiseoffices from offices
group by 1;

-- task3
-- 1.count number of products in each product line
select * from customers;
select * from orders;
select * from orderdetails;
select * from products;
select * from productlines;
select * from employees;
select * from offices;
select * from payments;
select productLine,count(productcode) as product from products
group by 1;
-- 2.find productLine with highes average product price
select productLine,avg(buyPrice) as product from products
group by 1;
-- 3. find all products with the price above or below a certain amount
select productCode from products where MSRP>50 and MSRP<100 ;
-- 4.find total sales from each product line
select productLine,sum(quantityOrdered*priceEach) as totalSales from products join orderdetails using(productCode)
group by 1;
-- 5.identify the products with low inventory levels (less than a specific threshold value of 10quantity in stock)
select productName from products where quantityInStock < 10;
-- 6.Retrive most expensive product based on MSRP
select productName,MSRP from products
where MSRP in(select max(MSRP) from products);
-- 7. Calculate total sales of each product 
select productName,sum(quantityOrdered*priceEach) as totalSales from products join orderdetails using(productCode)
group by 1;
-- 8.identify the top selling products based on quantity orderd usin gstored procedure
delimiter //
create procedure sp_topselling_product(in Code varchar(50),out state varchar(50))
begin
declare cn  int;
select sum(quantityOrdered) into cn from orderdetails where productCode = Code ;
if cn > 1060 then
set state = 'topselling product';
else 
set state = 'not topselling product';
end if;
end
//
delimiter ;
call sp_topselling_product('S12_4675',@state);
select @state;
-- 9. retrive the products with low inventory levels (less than a specific threshold value of 10quantity in stock) with specific product:ines
select productName,productLine from products where quantityInStock < 10;
-- 10.find the name of all products that have been orderd more than 10 customers
select productName, count(customerNumber) as no_of_orderdproducts from customers join orders using(customerNumber) 
join orderdetails using( orderNumber) join products using(productCode)
group by 1
having count(customerName)>10;
-- 11.find names of all products that have been ordered morethan the average number of orders for their productline
select p.productCode,p.productName,count(od.orderNumber) as ordercount from products p join
orderdetails od on p.productCode = od.productCode
group by p.productCode,p.productName
having count(od.orderNumber)>(select avg(ordercount) 
from (select productCode,count(orderNumber) as ordercount from orderdetails
group by productCode) as productaverage);