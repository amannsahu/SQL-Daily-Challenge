/*
Q1. Analyze order-to-delivery turnaround by sales channel

Calculate the delivery turnaround time for each sales channel.
- Display sales_channel, total delivered orders, average delivery days, minimum delivery days, and maximum delivery days.
- Calculate delivery days using DATEDIFF(delivered_date, order_date).
- Exclude orders where delivered_date is NULL.
- Group the results by sales channel.
- Sort by average delivery days from highest to lowest.
*/

SELECT
	sales_channel,
    
    COUNT(
		CASE
			WHEN order_status = "Delivered" THEN 1
		END
    ) AS total_delivered_orders,
    
    ROUND(AVG(DATEDIFF(delivered_date,order_date)),2) AS average_delivery_days,
    
    MIN(DATEDIFF(delivered_date,order_date)) AS minimum_delivery_days,
    
    MAX(DATEDIFF(delivered_date,order_date)) AS maximum_delivery_days
    
FROM orders
WHERE delivered_date IS NOT NULL
GROUP BY sales_channel
ORDER BY average_delivery_days DESC;