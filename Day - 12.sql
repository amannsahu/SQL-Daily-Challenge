/*
Q1. Identify customers who may share duplicate email addresses

The CRM team wants to identify customer records that may belong to the same person.
- Find email addresses shared by more than one customer.
- Ignore NULL and blank email values.
- Display the normalized email, number of matching customers, and customer IDs associated with the email.
- Sort by matching customer count descending.
*/

SELECT
	LOWER(TRIM(email)) AS Normalized_email,
    COUNT(*) AS matching_customers,
    GROUP_CONCAT(customer_id ORDER BY customer_id) AS customer_ids
FROM customers
WHERE email IS NOT NULL
	AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) >= 1
ORDER BY COUNT(*) DESC;

/*
Q2. Find customers who registered in the same city within 7 days of each other

The CRM analytiCs team wants to investigate clusters of new registrations that could reflect a campaign or unusual signup activity.
- Identify pairs of different customers from the same city whose signup dates are no more than seven days apart.
- Display both customer IDs, both signup dates, and the shared city.
- Include each customer pair only once.
- Sort by signup dates from oldest to newest.
*/

SELECT
	c.customer_id AS customer1_id,
    c.signup_date AS customer1_signup_date,
    c1.customer_id AS customer2_id,
    c1.signup_date AS customer2_signup_date,
    c.city AS shared_city
FROM customers c
JOIN customers c1
	ON c1.customer_id < c.customer_id
    AND c.city = c1.city
WHERE ABS(DATEDIFF(c.signup_date,c1.signup_date)) <= 7
ORDER BY
	c.signup_date,
    c1.signup_date;
    
/*
Q3. Find repeat purchasers and measure the gap between purchases

The retention team wants to understand how frequently customers place subsequent orders.
- Identify consecutive pairs of non-cancelled orders from the same customer.
- Display customer ID, earlier order ID and date, later order ID and date, and the number of days between the orders.
- Include pairs where the later order occurred within 30 days of the earlier order.
- Sort by the number of days between orders ascending.
*/

SELECT
	o1.customer_id,
    o1.order_id AS earlier_order_id,
    o1.order_date AS earlier_order_date,
    o2.order_id AS later_order_id,
    o2.order_date AS later_order_date,
    DATEDIFF(o2.order_date,o1.order_date) AS days_between_orders
    
FROM orders o1
JOIN orders o2
	ON o1.customer_id < o2.customer_id
	AND o1.order_date < o2.order_date
    
WHERE o1.order_status <> "Cancelled"
	AND o2.order_status <> "Cancelled"
    AND DATEDIFF(o2.order_date,o1.order_date) <= 30
    AND NOT EXISTS (
      SELECT 1
      FROM orders o3
      WHERE o3.customer_id = o1.customer_id
        AND o3.order_status <> 'Cancelled'
        AND o3.order_date > o1.order_date
        AND o3.order_date < o2.order_date
  )
    
ORDER BY DATEDIFF(o1.order_date,o2.order_date) ASC;

/*
Q4. Find products within the same category with similar prices

The merchandising team wants to identify products that customers might consider alternatives to one another.
- Identify pairs of different active products in the same category.
- Include pairs where the price difference is no greater than ₹500.
- Display both product IDs, product names, category IDs, prices, and the price difference.
- Show each pair only once.
- Sort by price difference ascending.
*/

SELECT
	p1.product_id AS p1_product_id,
    p1.product_name AS p1_product_name,
    p1.category_id AS p1_category_id,
    p1.unit_price AS p1_unit_price,
    
    p2.product_id AS p2_product_id,
    p2.product_name AS p2_product_name,
    p2.category_id AS p2_category_id,
    p1.unit_price AS p2_unit_price,
    
    ABS(p1.unit_price - p2.unit_price) AS price_difference
    
FROM products p1
JOIN products p2
	ON p1.category_id = p2.category_id
    AND p1.product_id < p2.product_id
    
WHERE p1.is_active = 1
	AND p2.is_active = 1
    AND ABS(p1.unit_price - p2.unit_price) <= 500
    
ORDER BY price_difference ASC;

/*
Q5. Identify customers who purchased the same product on multiple orders

The sales analytics team wants to identify customers who repeatedly purchase the same product.
- Identify pairs of different non-cancelled orders from the same customer that contain the same product.
- Display customer ID, product ID, both order IDs, both order dates, and the date gap.
- Include only pairs where the later order was placed within 90 days of the earlier order.
- Show each pair once and sort by date gap ascending.
*/

SELECT
	o1.customer_id,
    oi1.product_id,
    o1.order_id AS o1_order_id,
    o2.order_id AS o2_order_id,
    o1.order_date AS o1_order_date,
    o2.order_date AS o2_order_date,
    DATEDIFF(o2.order_date,o1.order_date) AS date_gap

FROM orders o1
JOIN orders o2
	ON o2.customer_id = o1.customer_id
    AND o1.order_id < o2.order_id
JOIN order_items oi1
	ON oi1.order_id = o1.order_id
JOIN order_items oi2
	ON oi2.order_id = o2.order_id
    AND oi2.product_id = oi1.product_id
    
WHERE o1.order_status <> "Cancelled"
	AND o2.order_status <> "Cancelled"
    AND o2.order_date >= o1.order_date
    AND DATEDIFF(o2.order_date,o1.order_date) <= 90
    
ORDER BY date_gap ASC;