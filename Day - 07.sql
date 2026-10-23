USE ecommerce_orders;

/*
Q1. Evaluate overall sales performance

The sales director wants a high-level summary of the order business.
- Calculate the total number of orders, total order value, average order value, minimum order value, and maximum order value.
- Use meaningful aliases for all five metrics.
- Consider whether cancelled orders should be included, and document your decision.
*/

SELECT
	COUNT(order_id) AS Total_Number_of_Orders,
    
    SUM(order_total) AS Total_Order_Value,
    
    ROUND(AVG(order_total),2) AS Average_Order_Value,
    
    MIN(order_total) AS Minimum_Order_Value,
    
    MAX(order_total) AS Maximum_Order_Value
    
FROM orders
WHERE NOT order_status = "Cancelled"; -- Excluding cancelled orders because they generally should not contribute to completed orer sales performance.

/*
Q2. Measure customer value

The CRM team wants to understand how much revenue customers generate on average.
- Calculate the number of distinct customers who placed orders, total order value, and average order value per order.
- Also calculate the average revenue per ordering customer.
- Exclude cancelled orders from the analysis.
*/

SELECT
	COUNT(DISTINCT customer_id) AS Number_of_Distinct_Customers,
    
    SUM(order_total) AS Total_Order_Value,
    
    ROUND(AVG(order_total),2) AS Average_Order_Value_Per_Order,
    
    ROUND(
		SUM(order_total) / NULLIF(COUNT(DISTINCT customer_id),'')
    ,2) AS Average_Revenue_Per_Ordering_Customer
    
FROM orders
WHERE NOT order_status = "Cancelled";

/*
Q3. Evaluate product sales and realized revenue

The merchandising team wants to understand which products contribute to sales.
- For each product, calculate units sold, number of order-item records, total line revenue, and average selling price per unit after discounts.
- Display the product name alongside the metrics.
- Exclude products with no qualifying sales from the result.
*/

SELECT
	p.product_name,
    
    SUM(oi.quantity) AS Total_Units_Sold,
    
	COUNT(oi.order_item_id) AS Number_of_Order_Items,
    
    SUM(oi.line_total) AS Total_Line_Revenue,
    
    ROUND(
		SUM(oi.line_total) / NULLIF(SUM(oi.quantity),'')
    ,2) AS Average_Selling_Price_Per_Unit

FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id
GROUP BY p.product_name
HAVING SUM(oi.quantity) > 0;

/*
Q4. Measure payment collection performance

The finance team wants to understand the value and volume of successful payments.
- Calculate the total number of payment attempts, number of successful payments, total amount associated with successful payments, average successful payment amount, and largest successful payment.
- Use the dataset's actual payment-status values.
- Do not count failed payment attempts as collected revenue.
*/

SELECT
	COUNT(payment_id) AS Total_Number_of_Payment_Attempts,
    
    COUNT(
		CASE
			WHEN payment_status = "Paid" THEN 1
		END
    ) AS Number_of_Successful_Payments,
    
    SUM(
		CASE
			WHEN payment_status = "Paid" THEN amount
			ELSE 0
		END
    ) AS Total_Successful_Payment_Amount,
    
    ROUND(
		SUM(
			CASE
				WHEN payment_status = "Paid" THEN amount
				ELSE 0
			END
		) / 
        COUNT(
			CASE
				WHEN payment_status = "Paid" THEN 1
			END
		)
    ,2) AS Average_Successful_Payment_Amount,
    
    MAX(
		CASE
			WHEN payment_status = "Paid" THEN amount
		END
    ) AS Largest_Successful_Payment_Amount
    
FROM payments;

/*
Q5. Assess delivery turnaround time

The logistics team wants to understand how quickly shipments are processed.
- Calculate the number of shipments, number of shipments with a recorded delivery date, average delivery turnaround time in days, minimum turnaround time, and maximum turnaround time.
- Calculate turnaround time using the difference between delivery_date and shipped_date.
- Exclude undelivered shipments from turnaround-time calculations, but report their count separately.
*/

SELECT
	COUNT(shipment_id) AS Number_of_Shipments,
    
    COUNT(
		CASE
			WHEN delivery_date IS NOT NULL THEN 1
		END
    ) AS Number_of_Delivered_Shipments,
    
    ROUND(
		AVG(
			CASE
				WHEN shipment_status = "Delivered"
					THEN DATEDIFF(delivery_date,shipped_date)
			END
        )
    ,2) AS Average_Delivery_Turnaround_Time,
    
    MIN(
		CASE
			WHEN shipment_status = "Delivered"
				THEN DATEDIFF(delivery_date,shipped_date)
		END
    ) AS Minimun_Turnaround_Time,
    
    MAX(
		CASE
			WHEN shipment_status = "Delivered"
				THEN DATEDIFF(delivery_date,shipped_date)
		END
    ) AS Maximum_Turnaround_Time
        
FROM shipments;