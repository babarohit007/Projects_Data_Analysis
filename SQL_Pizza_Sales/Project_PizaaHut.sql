create database pizzahut;
use pizzahut;
create table orders(
order_id int primary key,
order_date date not null,
order_time time not null
);

create table orders_details(
order_details_id int  primary key,
order_id int not null,
pizza_id text not null,
quantity int not null
);

describe orders_details;

-- Q1 Retrieve the total number of orders placed.
select count(*) from orders;

-- Q2 Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS Total_sales
FROM
    pizzas p
        JOIN
    orders_details od ON p.pizza_id = od.pizza_id;

-- Q3 Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered.
SELECT 
    size, COUNT(*) AS most_ordered_size
FROM
    pizzas p
        RIGHT JOIN
    orders_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY most_ordered_size DESC limit 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) as quantity
FROM
    orders_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY 2 DESC
LIMIT 5;

-- Intermediate Level

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    orders_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY quantity DESC; 

-- Q7. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hours, COUNT(*) AS order_count
FROM
    orders
GROUP BY hours
ORDER BY order_count DESC;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(*) AS count
FROM
    pizza_types
GROUP BY category;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(qty)) Daily_Average_Order
FROM
    (SELECT 
        order_date, SUM(quantity) AS qty
    FROM
        orders o
    JOIN orders_details od ON od.order_id = o.order_id
    GROUP BY order_date) AS daily_orders;

-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT     
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS sales
FROM
    orders_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY sales DESC
LIMIT 3;

-- ADVANCED -- 

-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

with helper as
(
select pt.category, sum(od.quantity * p.price) as revenue from orders_details od
join pizzas p on p.pizza_id = od.pizza_id 
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category)

select category, round(revenue *100 / (select sum(revenue) from helper),2) as Revenue_Share 
from helper order by revenue_share desc;

-- Q12. Analyze the cumulative revenue generated over time.

select * , sum(revenue) over(order by order_date) as cum_revenue from
(select o.order_date, round(sum(od.quantity * p.price),2) as revenue
 from orders_details od 
join orders o on o.order_id = od.order_id 
join pizzas p on p.pizza_id = od.pizza_id
group by order_date 
order by order_date) as sales;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with helper as (
select pt.category, pt.name, sum(od.quantity * p.price) as revenue 
from orders_details od join pizzas p on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category, pt.name
order by revenue desc)

select * from
(select *, 
rank() over (partition by category order by revenue desc) as rn from helper ) 
as rn_table
where rn <= 3; 
 



