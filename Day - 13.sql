/*
Q1. Identify customer contact data quality issues

Build a customer contact data quality report.
- Display customer_id, original email, trimmed email, lowercase email, and email length.
- Use TRIM() to remove leading and trailing spaces.
- Use LOWER() to standardize email casing.
- Use LENGTH() to calculate the number of bytes in the email.
- Flag records with NULL or empty emails after trimming.
- Also flag emails that appear to contain spaces after trimming, without assuming that every nonstandard email is invalid.
*/

SELECT
	customer_id,
    email AS original_email,
    TRIM(email) AS trimmed_email,
    LOWER(TRIM(email)) AS lowercase_email,
    LENGTH(email) AS email_length,
    
    CASE
		WHEN email IS NULL
			OR TRIM(email) = ''
        THEN "Empty Emails"
        ELSE "Emails Present"
	END AS email_status,
    
    CASE
		WHEN INSTR(TRIM(email), ' ') > 0
        THEN "Internal Spaces Found"
        ELSE "No Internal Spaces"
	END AS space_check
    
FROM customers;

/*
Q2. Generate standardized customer display names

Create a standardized customer name field.
- Display customer_id, first_name, last_name, and a standardized full name.
- Use TRIM() to clean each name component.
- Use CONCAT() to combine first and last names with a single space.
- Use COALESCE() to handle NULL name components.
- Avoid displaying unnecessary spaces when either name is missing.
- Flag records where both name components are missing or blank.
*/

SELECT
	customer_id,
    COALESCE(TRIM(first_name), 'Missing First Name') AS first_name,
    COALESCE(TRIM(last_name), 'Missing Last Name') AS last_name,
    COALESCE(CONCAT(first_name, ' ',last_name), 'Missing Name') AS full_name,
    
    CASE
		WHEN first_name IS NULL
			AND last_name IS NULL
		THEN "Missing Records"
        ELSE "Names Present"
	END AS name_check
    
FROM customers;

/*
Q4. Standardize product brand names

Find potentially inconsistent brand naming in the product catalog.
- Display the original brand, trimmed brand, uppercase brand, and product count.
- Group records by a normalized brand expression using TRIM() and UPPER().
- Identify normalized brand groups that contain more than one distinct original spelling or casing.
- Handle NULL and blank brand values separately rather than combining them with a real brand.
- Sort by the number of products in each normalized brand group.
*/


SELECT
    UPPER(TRIM(brand)) AS normalized_brand,
    COUNT(product_id) AS product_count,
    COUNT(DISTINCT brand) AS distinct_original_names
FROM products
WHERE brand IS NOT NULL
  AND TRIM(brand) <> ''
GROUP BY UPPER(TRIM(brand))
HAVING COUNT(DISTINCT BINARY brand) > 1
ORDER BY product_count DESC;

/*
Q5. Audit coupon code formatting

Analyze coupon-code data quality and usage.
- Display coupon_code, its trimmed version, its uppercase version, and the number of orders using it.
- Use TRIM() and UPPER() to create a normalized coupon code.
- Use COALESCE() to label missing codes as No Coupon.
- Count distinct orders for each normalized coupon category.
- Identify codes whose original values differ in whitespace or letter casing but normalize to the same value.
- Keep genuine missing values separate from literal text values such as "NULL".
*/

SELECT
	coupon_code,
    TRIM(coupon_code) AS trimmed_coupon,
    UPPER(TRIM(coupon_code)) AS uppercase_coupon,
    
    COUNT(
		CASE
			WHEN coupon_code IS NOT NULL THEN 1
		END
    ) AS number_of_orders,
    
    COALESCE(NULLIF(UPPER(TRIM(coupon_code)),''), 'No Coupon') AS normalized_coupon,
    
    COUNT(DISTINCT order_id) AS distinct_orders

FROM orders
GROUP BY coupon_code;

/*
Q6. Investigate shipping address text inconsistencies

Analyze shipping-city and shipping-state text quality.
- Display the original shipping_city and shipping_state, their trimmed versions, and their uppercase versions.
- Count distinct orders for each normalized city-state combination.
- Flag records with missing or blank city or state values.
- Identify combinations that differ only in casing or surrounding spaces.
- Do not automatically merge differently spelled cities without additional validation.
*/

SELECT
	shipping_city,
    shipping_state,
    
     TRIM(shipping_city) AS trimmed_city,
     TRIM(shipping_state) AS trimmed_state,
     
     UPPER(TRIM(shipping_city)) AS uppercase_city,
     UPPER(TRIM(shipping_state)) AS uppercase_state,
     
     CONCAT(
		shipping_city,
        ' - ',
        shipping_state
     ) AS city_state_combination,
     
     COUNT(DISTINCT order_id) AS distinct_orders
     
FROM orders
GROUP BY
	shipping_city,
    shipping_state
    
ORDER BY distinct_orders DESC;