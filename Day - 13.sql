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

/*
Q7. Create readable order reference labels

Generate a standardized display label for each order.
- Display order_id, customer_id, order_date, and the generated reference label.
- Use CONCAT() to combine a fixed prefix such as ORD- with the order ID.
- Use DATE_FORMAT() to include the order date in YYYYMMDD format.
- Use COALESCE() to provide a fallback label if any required component is missing.
- Ensure the output remains unique for each order.
*/

SELECT
	order_id,
    customer_id,
    order_date,
    COALESCE(
		CONCAT(
			CONCAT("ORD-",'',order_id),
            '-',
			DATE_FORMAT(order_date, '%Y/%m/%d')
        ),
        "Missing Details") AS order_reference_label
FROM orders;

/*
Q8. Analyze transaction reference formatting

Audit transaction reference strings.
- Display payment_id, transaction_reference, trimmed reference, uppercase reference, and string length.
- Use TRIM(), UPPER(), and LENGTH().
- Flag NULL, blank, and unusually short transaction references.
- Identify references that become identical after trimming and standardizing letter casing.
- Count duplicate normalized references, but do not label them confirmed duplicate transactions without further investigation.
*/

SELECT
	payment_id,
    transaction_reference,
    
    NULLIF(TRIM(transaction_reference),'') AS trimmed_reference,
    
    NULLIF(UPPER(TRIM(transaction_reference)),'') AS upper_reference,
    
    LENGTH(TRIM(transaction_reference)) AS string_length,
    
    CASE
		WHEN TRIM(transaction_reference) IS NULL
			THEN "Null Reference"
		WHEN transaction_reference = ''
			THEN "Blank Reference"
		WHEN LENGTH(TRIM(transaction_reference)) < 5
			THEN "Short Transaction"
		ELSE "Valid Transaction"
	END AS reference_status
    
FROM payments;

SELECT
    UPPER(TRIM(transaction_reference)) AS normalized_reference,
    COUNT(*) AS duplicate_count

FROM payments

WHERE transaction_reference IS NOT NULL
  AND TRIM(transaction_reference) <> ''

GROUP BY UPPER(TRIM(transaction_reference))

HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC;

/*
Q9. Standardize and analyze product name patterns

Investigate product names that may be inconsistently formatted.
- Display product_id, original product name, trimmed name, uppercase name, and name length.
- Identify names with leading or trailing spaces.
- Find product names that become identical after trimming and converting to uppercase.
- Use SUBSTRING() to display the first 5 characters of each normalized product name.
- Group products by this prefix and calculate the product count.
- Exclude blank names from prefix analysis.
*/

-- Product Name Formatting
SELECT
    product_id,
    product_name AS original_product_name,

    TRIM(product_name) AS trimmed_name,

    UPPER(TRIM(product_name)) AS uppercase_name,

    LENGTH(TRIM(product_name)) AS name_length,

    CASE
        WHEN product_name IS NULL
            THEN 'NULL Name'

        WHEN TRIM(product_name) = ''
            THEN 'Blank Name'

        WHEN product_name <> TRIM(product_name)
            THEN 'Extra Spaces'

        ELSE 'Properly Formatted'
    END AS formatting_status

FROM products;

-- Identifying duplicate normalized product name
SELECT
    UPPER(TRIM(product_name)) AS normalized_name,

    COUNT(*) AS product_count

FROM products

WHERE product_name IS NOT NULL
  AND TRIM(product_name) <> ''

GROUP BY UPPER(TRIM(product_name))

HAVING COUNT(*) > 1

ORDER BY product_count DESC;

-- Grouping products by their first five normalized characters
SELECT
    SUBSTRING(UPPER(TRIM(product_name)), 1, 5) AS name_prefix,

    COUNT(*) AS product_count

FROM products

WHERE product_name IS NOT NULL
  AND TRIM(product_name) <> ''

GROUP BY SUBSTRING(UPPER(TRIM(product_name)), 1, 5)

ORDER BY product_count DESC;