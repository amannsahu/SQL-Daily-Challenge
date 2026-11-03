/*
Q1. Identifying repeat customers

An e-commerce company wants to identify repeat customers for its loyalty program.

A customer is considered:
- One-Time Buyer: Exactly 1 completed order.
- Occasional Buyer: 2–4 completed orders.
- Frequent Buyer: 5–10 completed orders.
- Loyal Customer: More than 10 completed orders.
- Never Purchased: No completed orders.

Only completed orders should contribute to the classification. Customers without completed orders must also appear.
*/

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name) AS customer_name,
    COUNT(o.customer_id) AS completed_order,
    
    CASE
		WHEN COUNT(o.customer_id) = 1 THEN "One-Time Buyer"
        WHEN COUNT(o.customer_id) >= 2 AND COUNT(o.customer_id) <= 4 THEN "Occasional Buyer"
        WHEN COUNT(o.customer_id) >= 5 AND COUNT(o.customer_id) <= 10 THEN "Frequent Buyer"
        WHEN COUNT(o.customer_id) > 10 THEN "Loyal Customer"
        ELSE "No Completed Orders"
	END AS customer_type
    
FROM customers c
LEFT JOIN orders o
	ON o.customer_id = c.customer_id
    AND o.order_status = "Delivered"
    
GROUP BY
	c.customer_id,
    CONCAT(c.first_name, ' ',c.last_name);
    
/*
Q2. Finding potentially fraudulent transactions

A payment monitoring team wants to flag suspicious orders using the following rules:
- High Risk: Order amount >= 20,000 AND payment status is Failed.
- Medium Risk: Order amount >= 10,000 AND payment status is Pending.
- Low Risk: Order amount below 10,000 AND payment status is Failed.
- Normal: All other transactions.
Write a query that assigns a risk category to every payment transaction.
Important: Use the transaction amount and payment status together. Make sure the classification follows the specified priority.
*/

SELECT
	p.payment_id,
    o.order_id,
    o.order_total AS amount,
    p.payment_status,
    
    CASE
		WHEN o.order_total >= 20000 AND p.payment_status = "Failed"
			THEN "High Risk"
		WHEN o.order_total >= 10000 AND p.payment_status = "Pending"
			THEN "Medium Risk"
		WHEN o.order_total < 10000 AND p.payment_status = "Failed"
			THEN "Low Risk"
		ELSE "Normal"
	END AS risk_category
    
FROM orders o
JOIN payments p
	ON p.order_id = o.order_id;
    
/*
Q3. Detecting customers whose spending behavior has changed

The marketing team wants to identify customers who make high-value purchases versus customers who consistently make small purchases.

For each customer, calculate their average completed order value and classify them:
- High Spender: Average order value >= 15,000.
- Mid Spender: Average order value between 7,000 and 14,999.
- Low Spender: Average order value below 7,000.

Additionally, classify their purchasing frequency:
- Frequent: At least 5 completed orders.
- Infrequent: Fewer than 5 completed orders.
*/

SELECT
	c.customer_id,
    
    COUNT(o.customer_id) AS total_order,
    
    ROUND(AVG(o.order_total),2) AS avg_order_value,
    
    CASE
		WHEN ROUND(AVG(o.order_total),2) >= 15000 THEN "High Spender"
        WHEN ROUND(AVG(o.order_total),2) >= 7000 AND ROUND(AVG(o.order_total),2) <= 14999 THEN "Mid Spender"
        WHEN ROUND(AVG(o.order_total),2) < 7000 THEN "Low Spender"
        ELSE "No Records"
	END AS spending_category,
    
    CASE
		WHEN COUNT(o.customer_id) >= 5 THEN "Frequent"
        WHEN COUNT(o.customer_id) < 5 THEN "Infrequent"
	END AS frequency_category
    
FROM customers c
JOIN orders o
	ON o.customer_id = c.customer_id
    
WHERE o.order_status = "Delivered"

GROUP BY c.customer_id;

/*
Q4. Identifying products requiring pricing intervention

The pricing team wants to identify products that may need price adjustments.

Classify products using the following rules:
- High Profit: Margin >= 50%.
- Moderate Profit: Margin between 25% and 49.99%.
- Low Profit: Margin below 25%.
- Invalid Pricing: Price is zero or NULL, or cost is NULL.

Additionally, identify whether the product is expensive (price >= 10,000) or affordable (price < 10,000).
*/

SELECT
	product_id,
    product_name,
    unit_price,
    unit_cost,
    
    ROUND((unit_price - unit_cost)/unit_price * 100,2) AS profit_margin,
    
    CASE
		WHEN (unit_price - unit_cost)/unit_price * 100 >= 50 THEN "High Profit"
        WHEN (unit_price - unit_cost)/unit_price * 100 >= 25 AND (unit_price - unit_cost)/unit_price * 100 < 50 THEN "Moderate Profit"
        WHEN (unit_price - unit_cost)/unit_price * 100 < 25 THEN "Low Profit"
        WHEN unit_price IS NULL OR unit_cost IS NULL THEN "Invalid Pricing"
	END AS profit_category,
    
    CASE
		WHEN unit_price >= 10000 THEN "Expensive"
        WHEN unit_price < 10000 THEN "Affordable"
	END AS price_category
    
FROM products;

/*
Q5. Identifying delivery SLA violations

An e-commerce company promises delivery within a specific timeframe.

The logistics team wants to classify shipments based on the difference between expected and actual delivery dates.
- Early: Delivered at least 3 days before expected date.
- On Time: Delivered 0–2 days before expected date or on expected date.
- Minor Delay: Delivered 1–3 days after expected date.
- Major Delay: Delivered more than 3 days after expected date.
- In Transit: Actual delivery date is NULL.
*/

SELECT
	shipment_id,
    order_id,
    DATEDIFF(delivery_date,shipped_date) AS expected_delivery_date,
    delivery_date,
    