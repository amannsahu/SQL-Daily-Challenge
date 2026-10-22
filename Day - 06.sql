USE ecommerce_orders;

/*
Q1. Standardize customer names for CRM exports
The CRM team wants customer names in a consistent format for exporting records to a downstream marketing system.
From customers, display customer_id, first_name, last_name, and a cleaned full name.
- Remove leading and trailing spaces from both name fields using TRIM.
- Combine the cleaned first and last names using CONCAT.
- Display the cleaned full name in uppercase using UPPER.
- Return the 30 most recently registered customers.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    CONCAT(
		UPPER(TRIM(first_name)),
        " ",
		UPPER(TRIM(last_name))
    ) AS Cleaned_Full_Name
    
FROM customers
ORDER BY signup_date DESC
LIMIT 30;

/*
Q2. Classify product brands using string matching
The merchandising team wants to identify products whose brand contains tech, fashion, or home, regardless of letter case.
From products, display product_id, product_name, brand, unit_price, and a calculated brand_group.
- Use LOWER and LIKE to match the brand patterns.
- Classify matching brands as Tech, Fashion, or Home.
- Classify all other brands as Other.
- Include only active products.
- Sort by brand_group and then unit price descending.
*/

SELECT
	product_id,
    product_name,
    brand,
    unit_price,
    
    CASE
		WHEN LOWER(brand) LIKE "%tech%"
			OR LOWER(brand) LIKE "%fashion%"
				OR LOWER(brand) LIKE "%home%"
					THEN "Matching Brands"
		ELSE "Others"
	END AS brand_group
    
FROM products
WHERE is_active = 1
ORDER BY brand_group, unit_price DESC;

/*
Q3. Detect suspicious coupon-code formatting
The marketing operations team wants to identify coupon codes containing lowercase letters or leading/trailing spaces.
From orders, display order_id, coupon_code, a trimmed coupon code, and an uppercase normalized coupon code.
- Use TRIM to remove leading/trailing spaces.
- Use UPPER to standardize the trimmed code.
- Use LENGTH to display the original and normalized string lengths.
- Exclude missing coupon codes.
- Return records where the original value differs from the normalized value.
*/

SELECT
	order_id,
    coupon_code,
    TRIM(coupon_code) AS Trimmed_Coupon_Code,
    UPPER(TRIM(coupon_code)) AS Normalized_Coupon_Code,
    CHAR_LENGTH(coupon_code) AS Length_Coupon_Code,
    CHAR_LENGTH(UPPER(TRIM(coupon_code))) AS Length_Normalized_Coupon_Code
FROM orders
WHERE coupon_code IS NOT NULL
	AND CHAR_LENGTH(coupon_code) <> CHAR_LENGTH(UPPER(TRIM(coupon_code)));
    
/*
Q4. Create compact product labels for a catalog report
The product team wants short labels for products displayed in a limited-width report.
From products, display product_id, product_name, brand, and a product_label made from the first 12 characters of the product name, followed by a hyphen and the uppercase brand name.
- Use SUBSTRING to extract the first 12 characters.
- Use UPPER to standardize the brand.
- Use CONCAT to combine the components.
- Use COALESCE to replace a missing brand with 'UNKNOWN'.
- Sort alphabetically by product name.
*/

SELECT	
	product_id,
    product_name,
    brand,
    CONCAT(
		SUBSTRING(product_name,1,12),
        " - ",
        UPPER(COALESCE(brand, "unknown"))
    ) AS product_label
FROM products
ORDER BY product_name ASC;

/*
Q5. Build a standardized customer contact directory
The customer success team wants a clean directory with normalized names and a fallback value for missing contact details.
From customers, display customer_id, a cleaned full name, a normalized email, a phone display value, and the length of the cleaned full name.
- Use TRIM and CONCAT to create the full name.
- Use UPPER or LOWER to normalize text fields.
- Use COALESCE to show 'Email Missing' or 'Phone Missing' where appropriate.
- Use CHAR_LENGTH to calculate the length of the cleaned full name.
- Sort by full name alphabetically and return up to 50 records.
*/

SELECT
	customer_id,
    CONCAT(TRIM(first_name), " ", TRIM(last_name)) AS Cleaned_Full_Name,
    COALESCE(LOWER(TRIM(email)), "Email Missing") AS Customer_Email,
    COALESCE(TRIM(phone), "Phone Number Missing") AS Customer_Phone_Number,
    CHAR_LENGTH(CONCAT(TRIM(first_name), " ", TRIM(last_name))) AS Cleaned_Full_Name_Length
    
FROM customers
ORDER BY Cleaned_Full_Name ASC
LIMIT 50;

/*
Q6. Identify customers for a regional marketing campaign
The marketing team wants to target active customers in selected metropolitan markets who registered through specific acquisition channels.
- Display customer_id, first_name, last_name, city, state, acquisition_channel, and signup_date.
- Include customers from Hyderabad, Bengaluru, Pune, or Mumbai.
- Include only active customers acquired through either Social Media or Referral.
- Include customers who registered between 1 January 2024 and 31 December 2025, inclusive.
- Sort by signup date from newest to oldest.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    city,
    state,
    acquisition_channel,
    signup_date
FROM customers
WHERE city IN ("Hyderabad", "Bengaluru", "Pune", "Mumbai")
	AND is_active = 1 AND acquisition_channel IN ("Social Media", "Referral")
    AND signup_date BETWEEN '2024-01-01' AND '2025-12-31'
ORDER BY signup_date DESC;

/*
Q7. Find potentially underperforming products
The merchandising team wants to identify products that may need pricing or inventory intervention.
- Display product_id, product_name, brand, unit_price, unit_cost, and stock_quantity.
- Include active products where stock is below 10 units or the difference between selling price and unit cost is below ₹300.
- Exclude products priced below ₹500.
- Sort by stock quantity ascending and then selling price descending.
- Return the top 25 records.
*/

SELECT
	product_id,
    product_name,
    brand,
    unit_price,
    unit_cost,
    stock_quantity
FROM products
WHERE is_active = 1
	AND (
		stock_quantity < 10 
        OR unit_price - unit_cost < 300
	)
	AND NOT unit_price < 500
ORDER BY 
	stock_quantity ASC, 
    unit_price DESC
LIMIT 25;

/*
Q8. Investigate orders with inconsistent promotional information
The marketing operations team wants to review orders with missing coupon codes or coupon codes following a particular naming convention.
- Display order_id, order_date, coupon_code, sales_channel, order_status, and order_total.
- Include orders where the coupon code starts with SAVE or is NULL.
- Restrict the results to orders placed between 1 July 2025 and 31 December 2025.
- Use COALESCE to display missing coupon codes as 'No Coupon Recorded'.
- Sort by order total from highest to lowest.
*/

SELECT
	order_id,
    order_date,
    COALESCE(coupon_code, "No Coupon Recorded") AS coupon_code,
    sales_channel,
    order_status,
    order_total
FROM orders
WHERE (coupon_code LIKE "SAVE%" OR coupon_code IS NULL)
	AND (order_date >= "2025-07-01" AND order_date <= "2025-12-31")
ORDER BY order_total DESC;

/*
Q9. Build a customer contact data-quality report
The CRM team wants to identify customer records with incomplete or inconsistently formatted contact information.
- Display customer_id, first_name, last_name, email, and phone.
- Create a normalized email field using LOWER(TRIM(email)).
- Display 'Email Missing' when the email is NULL or contains only spaces.
- Include records with missing email or phone details, or where the original email differs from its normalized form.
- Sort by customer ID ascending.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    COALESCE(NULLIF(TRIM(email),''), "Email Missing") AS Customer_Email,
    LOWER(TRIM(email)) AS Normalized_Email,
    phone
FROM customers
WHERE TRIM(email) IS NULL
	OR TRIM(phone) IS NULL
	OR email <> LOWER(TRIM(email))
ORDER BY customer_id ASC;

/*
Q10. Identify delayed or unresolved shipments for review
The logistics team wants to create a worklist of shipments that may need investigation.
- Display shipment_id, order_id, courier, shipment_status, shipped_date, delivery_date, and tracking_number.
- Include shipments whose status is either In Transit or Delayed, or whose tracking number is NULL.
- Exclude shipments that have not yet been shipped, if the dataset contains such records.
- Use COALESCE to display missing tracking numbers as 'Tracking Unavailable'.
- Sort by shipped date from oldest to newest.
*/

SELECT
	shipment_id,
    order_id,
    courier,
    shipment_status,
    shipped_date,
    delivery_date,
    COALESCE(tracking_number, "Tracking Unavailable") AS Tracking_Number
FROM shipments
WHERE (shipment_status IN ("In Transit", "Delayed") OR tracking_number IS NULL)
	AND shipped_date IS NOT NULL
ORDER BY shipped_date ASC;