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