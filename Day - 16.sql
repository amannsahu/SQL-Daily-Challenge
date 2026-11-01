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