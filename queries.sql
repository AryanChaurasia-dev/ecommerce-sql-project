select * from customers;
select * from addresses;
select * from categories;
select * from products;
select * from orders;
select * from order_items;
select *from payments;
select * from shipments;
select * from reviews;
select * from cart;
select * from cart_items;
select * from wishlist;
select * from inventory_log;
use e_commerce;

-- active customers registerd in 2024
select * from customers where status = 'Active' and year(created_at) = 2024;

--  customers with more than 5 orders
SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) AS order_count
FROM Customers c
inner JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 5
ORDER BY order_count DESC;


--  Top 5 Most Expensive Available Product.
select * from products 
where status = 'Available'
order by price desc
limit 5;


--  Total Revenue from Delivered Orders in June 2024
select sum(total_amount) as total_revenue from orders 
where order_status = 'Delivered' 
and year(order_date) = 2024
and month(order_date) = 6;

-- 5 Products That Have Never Been Ordered.
select product_id,product_name,price
from products
where product_id not in (select product_id from order_items); 

select * from order_items where product_id in (4,7,17,20,32,33);


-- 6 Average Price & Product Count per Category
select count(p.product_name) as product_count , round(avg(p.price),2) as avg_price, c.category_name
from products p 
right join categories c
on p.category_id = c.category_id
group by c.category_id,c.category_name;


 -- 7 Customers Who Ordered but Never Wrote a Review.
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.customer_id NOT IN (SELECT customer_id FROM reviews);

-- 8 Products with the Highest Price.
select product_name , price as max_price
from products where price = (select max(price) from products);

select product_name, price
from products 
order by price desc
limit 1;


-- 9 Orders Where Item Totals Don't Match Order Total.
SELECT o.order_id, o.total_amount AS order_total,
       SUM(oi.quantity * oi.unit_price) AS items_total
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING ABS(o.total_amount - SUM(oi.quantity * oi.unit_price)) > 0.01;


-- 10 Monthly Order Count for Year 2023.
select month(order_date) ,count(*) as total_order 
from orders where year(order_date) = 2023
group by month(order_date)
order by month(order_date);


-- 11 Top 3 Customers by Total Spending.
select c.customer_id, c.first_name,c.last_name, sum(o.total_amount) as total_spending
from customers c  
inner join orders o 
on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_spending desc
limit 3;

-- 12 Most Popular Product Category by Items Sold.
select c.category_name,sum(oi.quantity) as item_sold
from categories c
inner join products p
on c.category_id = p.category_id 
inner join order_items oi
on p.product_id = oi.product_id
group by c.category_name
order by sum(oi.quantity) desc
limit 1;

-- 13 Customers Who Wishlisted but Never Bought.
SELECT DISTINCT c.customer_id, c.first_name, c.last_name, p.product_name
FROM wishlist w
JOIN customers c ON w.customer_id = c.customer_id
JOIN products p ON w.product_id = p.product_id
WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.customer_id = w.customer_id 
    AND oi.product_id = w.product_id
);


-- 14 Shipping & Payment Status for Each Order.
select o.order_id,c.first_name,c.last_name,s.shipment_status, p.payment_status
from orders o 
join customers c
on o.customer_id = c.customer_id
left join shipments s 
on o.order_id = s.order_id
left join payments p
on s.order_id = p.order_id;

-- 15 Reduce Stock When an Order is Placed. 
UPDATE Products
SET stock_quantity = stock_quantity - 5  -- jo quantity order hui
WHERE product_id = 10;  -- jo product order hua


-- 16 Top 10 Customers by Lifetime Value
select c.customer_id, c.first_name, c.last_name, round(sum(o.total_amount),0) as total_spent, round(avg(o.total_amount),0) as avg_order_value
from customers c 
join orders o
on c.customer_id = o.customer_id
where order_status = 'Delivered'
group by c.customer_id, c.first_name, c.last_name
order by total_spent desc
limit 10;

-- 17 Top 5 Best-Selling Products by Revenue.
SELECT p.product_name, 
       SUM(oi.quantity) AS total_units_sold,
       SUM(oi.quantity * oi.unit_price) AS total_revenue,
       COUNT(DISTINCT oi.order_id) AS order_count
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 5;

--  18 Products with High Return Rate.
SELECT p.product_id, p.product_name,COUNT(*) AS total_returns,ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) 
         FROM Order_Items oi2 
         WHERE oi2.product_id = p.product_id), 2
    ) AS return_rate_percentage
FROM Order_Items oi
JOIN Orders o ON oi.order_id = o.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Returned'
GROUP BY p.product_id, p.product_name
ORDER BY return_rate_percentage DESC; 


-- 19 Low Stock Alert — Products Running Out
SELECT p.product_name, p.stock_quantity,
       SUM(oi.quantity) AS units_sold_last_30d
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
AND p.stock_quantity < 10
GROUP BY p.product_id, p.product_name, p.stock_quantity
ORDER BY units_sold_last_30d DESC;


-- 20 Customer Churn Risk (No Orders in 90 Days)
SELECT c.first_name, c.last_name,
       MAX(o.order_date) AS last_order_date,
       DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING DATEDIFF(CURDATE(), MAX(o.order_date)) > 90
ORDER BY days_since_last_order DESC;


-- 21 Payment Method Preference by City.
SELECT a.city, pay.payment_method,
       COUNT(*) AS order_count,
       SUM(pay.amount) AS total_revenue
FROM orders o
JOIN addresses a ON o.address_id = a.address_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY a.city, pay.payment_method
ORDER BY a.city, total_revenue DESC;


-- 22 Average Delivery Time by Courier.
SELECT courier_name,
       COUNT(*) AS total_shipments,
       ROUND(AVG(TIMESTAMPDIFF(HOUR, shipment_date, delivery_date)), 2) AS avg_delivery_hours
FROM shipments
WHERE shipment_date IS NOT NULL AND delivery_date IS NOT NULL
GROUP BY courier_name
ORDER BY avg_delivery_hours ASC;

-- 23 Orders Missing Payment or Shipment.
SELECT o.order_id, o.order_date,
       CASE WHEN p.payment_id IS NULL THEN 'Missing Payment' ELSE 'Payment OK' END AS payment_check,
       CASE WHEN s.shipment_id IS NULL THEN 'Missing Shipment' ELSE 'Shipment OK' END AS shipment_check
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE p.payment_id IS NULL OR s.shipment_id IS NULL;


-- 24 Monthly Active Customers.
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       COUNT(DISTINCT customer_id) AS active_customers
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- 25 Products Bought Together Most Often.
SELECT a.product_id AS product_1, b.product_id AS product_2,
       COUNT(*) AS times_bought_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY times_bought_together DESC
LIMIT 10;


-- 26 RFM Analysis (Customer Segments).
SELECT customer_id,
       DATEDIFF(CURDATE(), MAX(order_date)) AS recency_days,
       COUNT(order_id) AS frequency,
       SUM(total_amount) AS monetary,
       CASE
           WHEN DATEDIFF(CURDATE(), MAX(order_date)) <= 30 AND COUNT(order_id) >= 5 THEN 'Champion'
           WHEN DATEDIFF(CURDATE(), MAX(order_date)) > 90 THEN 'At Risk'
           ELSE 'Regular'
       END AS segment
FROM orders
GROUP BY customer_id;


-- 27 Daily Orders & Revenue (Last 30 Days)
SELECT DATE(order_date) AS order_day,
       COUNT(*) AS orders,
       SUM(total_amount) AS revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(order_date)
ORDER BY order_day DESC;


-- 28 Customers Who Bought from 3+ Categories
SELECT o.customer_id,
       COUNT(DISTINCT p.category_id) AS categories_purchased,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category_id) >= 3
ORDER BY categories_purchased DESC;


-- 29 Pending Orders Stuck for 3+ Days.
SELECT o.order_id, o.order_status,
       DATEDIFF(CURDATE(), o.order_date) AS days_waiting,
       CASE 
           WHEN s.shipment_status = 'In Transit' THEN 'In Transit'
           ELSE 'Not Yet Shipped'
       END AS progress
FROM orders o
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE o.order_status IN ('Confirmed', 'Shipped')
AND DATEDIFF(CURDATE(), o.order_date) > 3
ORDER BY days_waiting DESC;


-- 30 Wishlist to Purchase Conversion Rate.
SELECT COUNT(*) AS total_wishlist_entries,
       SUM(CASE WHEN converted_check.order_item_id IS NOT NULL THEN 1 ELSE 0 END) AS converted,
       ROUND(SUM(CASE WHEN converted_check.order_item_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate_percent
FROM wishlist w
LEFT JOIN (
    SELECT oi.product_id, o.customer_id, oi.order_item_id
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
) AS converted_check
ON w.customer_id = converted_check.customer_id AND w.product_id = converted_check.product_id;

-- 31 Business wants to send a discount coupon to customers who haven't ordered in the last 30 days. Find those customers.
SELECT c.customer_id, c.first_name, c.last_name, 
       c.email,
       MAX(o.order_date) AS last_order_date,
       DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
HAVING DATEDIFF(CURDATE(), MAX(o.order_date)) > 30
ORDER BY days_since_last_order DESC;

SELECT customer_id,
       MAX(order_date) AS last_order_date
FROM orders
GROUP BY customer_id
HAVING MAX(order_date) < CURDATE() - INTERVAL 30 DAY;

-- 32 Warehouse team needs to restock products. Show all products where stock is below 50, ordered by stock quantity ascending.
select product_id, product_name, stock_quantity 
from products 
where stock_quantity<50
order by stock_quantity asc;

-- 33  Marketing wants to target Active customers who have spent more than 50000 total. Find those customers.
select c.customer_id, c.first_name, c.status, sum(o.total_amount) as total_spend
from customers c
inner join orders o
on c.customer_id=o.customer_id
where c.status = "Active" 
group by c.customer_id, c.first_name, c.status
having total_spend>50000;

-- 34 Finance needs a report: show total revenue, total orders, and average order value for the entire store.
select count(order_id) as total_orders, 
sum(total_amount) as total_revenue, 
round(avg(total_amount),2) as avg_order_value
from orders
where order_status="Delivered";

-- 35  Operations team wants to see all pending and shipped orders with customer contact (email) and order date.
select c.customer_id, c.first_name, c.email, c.phone, 
o.order_date, o.order_status
from customers c
join orders o
on c.customer_id = o.customer_id
where o.order_status in ("Shipped" , "Pending");

-- 36  Product team wants to know which products are selling well — show top 5 products by total quantity sold.
select p.product_id, p.product_name, p.price, 
sum(oi.quantity) as total_quantity_sold, 
SUM(oi.quantity * p.price) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
group by p.product_id, p.product_name, p.price
order by total_quantity_sold desc
limit 5;

-- 37  Customer support needs a list of all cancelled orders with customer name and email.
select c.customer_id, c.first_name, c.email,
o.order_date, o.order_status
from customers c
join orders o 
on c.customer_id = o.customer_id
where o.order_status = "Cancelled" and year(o.order_date)=2024;    


--  Management wants city-wise performance: show each city's total customers, total orders, and total revenue.
select count(distinct(a.customer_id)) as total_customers, a.city, 
count(o.order_id) as total_orders, 
sum(o.total_amount) as total_revenue
from customers c 
join addresses a
on c.customer_id = a.customer_id
join orders o
on a.address_id = o.address_id
group by  a.city
ORDER BY total_revenue DESC;


-- Find all customers whose total spending is more than the average spending of all customers.
select distinct c.customer_id, c.first_name, sum(o.total_amount) as total_spending
from customers c
join orders o 
on c.customer_id = o.customer_id 
group by c.customer_id, c.first_name
having sum(o.total_amount) > ( select avg(total_amount) from orders);

-- given by copilot.
SELECT c.customer_id, 
       c.first_name, 
       SUM(o.total_amount) AS total_spending
FROM customers c
JOIN orders o 
  ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total) 
    FROM (
        SELECT SUM(total_amount) AS customer_total
        FROM orders
        GROUP BY customer_id
    ) AS subquery
);


-- Show all products whose price is higher than the average price of their own category.
select product_id, product_name, max(price) as high_price
from products 
group by product_id, product_name
having max(price) > (select avg(price) from products);


use e_commerce;





--                                                                PROJECT COMPLETED