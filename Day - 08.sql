/*
Q1. Which customer acquisition channels generate the most revenue?

The marketing director wants to compare the commercial value of customers acquired through different channels.
- Group customers' orders by acquisition_channel.
- Calculate distinct ordering customers, total orders, total order value, and average order value.
- Exclude cancelled orders.
- Display only channels with at least 20 distinct ordering customers.
- Sort by total order value from highest to lowest.
*/

SELECT
	c.acquisition_channel,
    
    COUNT(DISTINCT o.customer_id) AS Ordering_Customers,
    
    SUM(o.order_total) AS total_orders,
    
    ROUND(AVG(o.order_total),2) AS Average_Order_Value
    
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id
WHERE order_status <> "Cancelled"
GROUP BY c.acquisition_channel
HAVING COUNT(DISTINCT o.customer_id) >= 20
ORDER BY total_orders DESC;

/*
Q2. Which cities are the strongest sales markets?

The regional sales team wants to identify cities with consistently meaningful sales activity.
- Group orders by shipping_state and shipping_city.
- Calculate order count, total order value, and average order value.
- Exclude cancelled orders.
- Show only city–state combinations with at least 15 qualifying orders.
- Sort by total order value descending.
*/

SELECT
	shipping_city,
    shipping_state,
    
	COUNT(order_id) AS order_count,
    
    SUM(order_total) AS total_order_value,
    
    ROUND(AVG(order_total),2) AS average_order_value
    
FROM orders
WHERE order_status <> "Cancelled"
GROUP BY shipping_city, shipping_state
HAVING COUNT(order_id) >= 15
ORDER BY total_order_value DESC;

/*
Q3. Which products are major revenue contributors?

The merchandising team wants to find products that generate substantial item-level revenue.
- Group qualifying order items by product.
- Calculate total units sold, distinct orders containing the product, total line revenue, and average line-item value.
- Exclude items belonging to cancelled orders.
- Show products with at least 20 units sold and item-level revenue above ₹25,000.
- Sort by revenue descending.
*/

SELECT
	p.product_id,
    p.product_name,
    
	SUM(oi.quantity) AS total_units_sold,
    
    COUNT(DISTINCT oi.order_item_id) AS distinct_orders,
    
    SUM(oi.line_total) AS total_line_revenue,
    
    ROUND(AVG(oi.line_total),2) AS Average_line_item_value

FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
JOIN products p
	ON oi.product_id = p.product_id
WHERE o.order_status <> "Cancelled"
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) >= 20 AND SUM(oi.line_total) > 25000
ORDER BY total_line_revenue DESC;

/*
Q4. Which product categories have the highest average selling price?

The category manager wants to compare realized selling prices across categories.
- Group by category name.
- Calculate units sold, total line revenue, and weighted average selling price per unit.
- Exclude cancelled orders.
- Show categories with at least 50 units sold.
- Sort by weighted average selling price descending.
*/

SELECT
	c.category_name,
    
	SUM(oi.quantity) AS units_sold,
    
    SUM(oi.line_total) AS total_line_revenue,
    
    ROUND(AVG(p.unit_price) / NULLIF(SUM(oi.quantity),0),2) AS weighted_avgerage_selling_price
    
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
JOIN categories c
	ON p.category_id = c.category_id
    
GROUP BY c.category_name
HAVING SUM(oi.quantity) >= 50
ORDER BY weighted_avgerage_selling_price DESC;

/*
Q5. Which couriers handle the largest shipment volumes?

The logistics manager wants to compare courier workload and delivery outcomes.
- Group shipments by courier.
- Calculate total shipments, number of delivered shipments, and average shipping cost.
- Show couriers with at least 20 shipments.
- Sort by shipment count descending.
*/

SELECT
	courier,
    
    COUNT(shipment_id) AS total_shipments,
    
    COUNT(
		CASE
			WHEN shipment_status = "Delivered" THEN 1
		END
    ) AS Number_of_Delivered_Shipments,
    
    ROUND(AVG(shipping_cost),2) AS Average_shipping_cost
    
FROM shipments
GROUP BY courier
HAVING COUNT(shipment_id) >= 20
ORDER BY total_shipments DESC;