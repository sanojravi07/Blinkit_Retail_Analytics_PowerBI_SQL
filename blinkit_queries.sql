-- =====================================
-- BLINKIT_RETAIL_ANALYTICS_POWER-BI_SQL PROJECT
-- Author: Sanoj Poojari
-- =====================================

-- BASIC QUERIES
-- 1.Total number of orders

SELECT 
    COUNT(order_id) AS total_order_count
FROM
    blinkit_orders;

-- 2.Total revenue generated

SELECT 
    ROUND(SUM(order_total), 2) AS total_revenue
FROM
    blinkit_orders;

-- 3.Total customers

SELECT 
    COUNT(customer_id) AS total_customers
FROM
    blinkit_customers;

-- 4.Average order value

SELECT 
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM
    blinkit_orders;

-- 5.Most used payment method

SELECT 
    payment_method, COUNT(payment_method) AS payment_count
FROM
    blinkit_orders
WHERE
    payment_method IS NOT NULL
GROUP BY payment_method
ORDER BY payment_count DESC
LIMIT 1;

-- INTERMIDIATE QUERIES
-- 6.Monthly revenue trend

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(order_total), 2) AS revenue
FROM
    blinkit_orders
GROUP BY month
ORDER BY month;

-- 7.Orders by delivery status

SELECT 
    delivery_status, COUNT(*) AS total_orders
FROM
    blinkit_orders
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- 8.Revenue by category

SELECT 
    p.category AS product_category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM
    blinkit_products p
        JOIN
    blinkit_order_items oi ON p.product_id = oi.product_id
GROUP BY product_category
ORDER BY revenue DESC;

-- 9.Top 10 products by revenue

SELECT 
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM
    blinkit_products p
        JOIN
    blinkit_order_items oi
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 10.Top areas by orders

SELECT 
    c.area, COUNT(o.order_id) AS total_order
FROM
    blinkit_customers c
        JOIN
    blinkit_orders o ON c.customer_id = o.customer_id
GROUP BY c.area
ORDER BY total_order DESC;

-- 11.Customer segment-wise revenue

SELECT 
    c.customer_segment,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM
    blinkit_customers c
        JOIN
    blinkit_orders o ON c.customer_id = o.customer_id
        JOIN
    blinkit_order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_segment
ORDER BY revenue DESC;

-- ADVANCE QUERIES
-- 12.Repeat customers vs one-time customers

SELECT 
    CASE
        WHEN order_count = 1 THEN 'One time customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customer
FROM
    (SELECT 
        blinkit_orders.order_id,
            COUNT(blinkit_orders.order_id) AS order_count
    FROM
        blinkit_orders
    GROUP BY blinkit_orders.order_id
    ORDER BY order_count DESC) AS count
GROUP BY customer_type;

-- 13.Running total revenue over time

SELECT date, daily_revenue, ROUND(SUM(daily_revenue) OVER (ORDER BY date), 2) AS running_revenue
FROM
(SELECT 
    DATE(order_date) AS date,
    ROUND(SUM(order_total), 2) AS daily_revenue
FROM
    blinkit_orders
GROUP BY date) AS o_date
GROUP BY date
ORDER BY date;

-- 14.Top brands by margin contribution

SELECT 
    brand,
    ROUND(SUM(((price * margin_percentage) / 100) * oi.quantity),
            2) AS margin_contribution
FROM
    blinkit_products
        JOIN
    blinkit_order_items oi ON blinkit_products.product_id = oi.product_id
GROUP BY brand
ORDER BY margin_contribution DESC;

-- 15.Product ranking within each category

SELECT category, product_name, revenue, RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS product_ranking
FROM
(SELECT 
    p.category,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM
    blinkit_products p
        JOIN
    blinkit_order_items oi ON p.product_id = oi.product_id
GROUP BY p.category , p.product_name
ORDER BY revenue DESC) AS cpnr;

-- 16.Average delivery delay

SELECT 
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                promised_delivery_time,
                actual_delivery_time)),
            2) AS average_delivery_delay_in_minutes
FROM
    blinkit_orders
WHERE
    promised_delivery_time IS NOT NULL
        AND actual_delivery_time IS NOT NULL;

-- 17.Best performing stores by revenue

SELECT 
    store_id, ROUND(SUM(order_total), 2) AS revenue
FROM
    blinkit_orders
GROUP BY store_id
ORDER BY revenue DESC;