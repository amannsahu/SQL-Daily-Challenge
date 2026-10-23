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

/*
Q6. Measure return and refund exposure

The finance team wants to understand the overall impact of product returns.
- Calculate the total number of return records, total refund amount, average refund amount, minimum refund amount, and maximum refund amount.
- Also calculate the number of approved returns using the dataset's actual return-status values.
*/

SELECT
	COUNT(return_id) AS Total_Number_of_Returns,
    
    SUM(refund_amount) AS Total_Refund_Amount,
    
    ROUND(AVG(refund_amount),2) AS Average_Refund_Amount,
    
    MIN(refund_amount) AS Minimum_Refund_Amount,
    
    MAX(refund_amount) AS Maximum_Refund_Amount,
    
    COUNT(
		CASE
			WHEN return_status = "Approved" THEN 1
		END
    ) AS Number_of_Approved_Returns
    
FROM returns;

/*
Q7. Identify customer acquisition patterns

Marketing wants to compare customer acquisition channels.
- Calculate the total number of customers, number of active customers, and number of customers with a recorded signup date.
- Calculate the earliest and latest signup dates.
- Report the number of customers with missing acquisition-channel information.
*/

SELECT
	COUNT(customer_id) AS Number_of_Customers,
    
    COUNT(
		CASE
			WHEN is_active = 1 THEN 1
		END
    ) AS Number_of_Active_Customers,
    
    COUNT(
		CASE
			WHEN signup_date IS NOT NULL THEN 1
		END
    ) AS Customers_with_signup_date,
    
    MIN(signup_date) AS Earliest_Signup_Date,
    
    MAX(signup_date) AS Latest_signup_date,
    
    COUNT(
		CASE
			WHEN acquisition_channel IS NULL THEN 1
		END
    ) AS Missing_Acquisition_Channel_Customers
    
FROM customers;

/*
Q8. Evaluate product inventory investment

The inventory manager wants to quantify the current inventory position.
- Calculate total units in stock, total inventory cost using unit_cost * stock_quantity, average product price, minimum product price, and maximum product price.
- Include only active products in the inventory analysis.
- Use meaningful aliases for all metrics.
*/

SELECT
	SUM(stock_quantity) AS Total_Stock_Units,
    
    SUM(stock_quantity * unit_cost) AS Total_Inventory,
    
    ROUND(AVG(unit_price),2) AS Average_product_price,
    
    MIN(unit_price) AS Minimum_product_price,
    
    MAX(unit_price) AS Maximum_product_price
    
FROM products
WHERE is_active = 1;

/*
Q9. Analyze customer review quality

The customer experience team wants to understand customer feedback.
- Calculate the total number of reviews, average rating, minimum rating, maximum rating, and number of reviews with missing review text.
- Also calculate the number of reviews rated 1 or 2.
- Keep in mind that aggregate functions such as AVG and MIN ignore NULL values.
*/

SELECT
	COUNT(review_id) AS Number_of_reviews,
    
    ROUND(AVG(rating),2) AS Average_Rating,
    
    MIN(rating) AS Minimum_Rating,
    
    MAX(rating) AS Maximum_Rating,
    
    COUNT(
		CASE
			WHEN review_text IS NULL THEN 1
		END
    ) AS Number_of_missing_review_text,
    
	COUNT(
		CASE
			WHEN rating IN (1,2) THEN 1
		END
    ) AS Low_Review_Ratings
    
FROM reviews;

/*
Q10. Compare order totals with item-level revenue

Finance wants to compare recorded order totals with the revenue represented by individual order items.
- Calculate the number of orders, sum of orders.order_total, and sum of order_items.line_total.
- Exclude cancelled orders from both calculations.
- Investigate why the totals may differ, considering shipping fees, taxes, and the distinction between order-level and item-level values.
*/

SELECT
	COUNT(DISTINCT o.order_id) AS Number_of_Orders,
    
    SUM(
		CASE
			WHEN o.order_status <> "Cancelled" THEN o.order_total
		END
    ) AS Sum_Order_Total,
    
    SUM(
		CASE
			WHEN o.order_status <> "Cancelled" THEN oi.line_total
		END
    ) AS Sum_Line_Total
    
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id;