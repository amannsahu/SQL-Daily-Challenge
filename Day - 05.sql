USE ecommerce_orders;

/*
Q1. Find customer records with incomplete contact details
The CRM team needs a list of active customers whose email address or phone number is missing.
From customers, display customer_id, first_name, last_name, email, phone, city, and acquisition_channel.
- Include active customers with a missing email or phone.
- Use COALESCE to display 'Not Provided' wherever email or phone is NULL.
- Sort by signup date from newest to oldest.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    COALESCE(email, 'Not Provided') AS Customer_Email,
    COALESCE(phone, 'Not Provided') AS Customer_Phone_Number,
    city AS Customer_City,
    acquisition_channel
FROM customers
WHERE is_active = 1 
	AND (email IS NULL OR phone IS NULL)
ORDER BY signup_date DESC;

/*
Q2. Analyze coupon usage and missing coupon information
The marketing team wants to review orders with either a coupon code beginning with FEST or no coupon code recorded.
From orders, display order_id, order_date, coupon_code, sales_channel, and order_total.
- Include orders where coupon_code matches the specified pattern or is NULL.
- Use COALESCE to show missing coupon codes as 'No Coupon Recorded'.
- Sort by order total descending.
- Return the top 30 records.
*/

SELECT
	order_id,
    order_date,
    COALESCE(coupon_code, "No Coupon Recorded") AS Coupon_Code,
    sales_channel,
    order_total
FROM orders
WHERE coupon_code LIKE "FEST%" 
	OR coupon_code IS NULL
ORDER BY order_total DESC
LIMIT 30;

/*
Q3. Identify reviews that need follow-up
The customer experience team wants to identify low-rated reviews with missing review text.
From reviews, display review_id, customer_id, product_id, rating, review_date, and review_text.
- Include reviews with a rating of 1 or 2 and a missing review text.
- Use COALESCE to display 'No Written Feedback' when the text is NULL.
- Sort by review date from newest to oldest.
*/

SELECT
	review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    COALESCE(review_text, "No Written Feedback") AS review_text
FROM reviews
WHERE rating IN (1,2)
	AND review_text IS NULL
ORDER BY review_date DESC;

/*
Q4. Find potentially incomplete shipment records
The logistics team wants to investigate shipments with missing delivery dates or tracking numbers.
From shipments, display shipment_id, order_id, courier, shipment_status, shipped_date, delivery_date, and tracking_number.
- Include shipments where either delivery_date or tracking_number is NULL.
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
    COALESCE(tracking_number, "Tracking Unavailable") AS tracking_number
FROM shipments
WHERE delivery_date IS NULL
	OR tracking_number IS NULL
ORDER BY shipped_date ASC;

/*
Q5. Identify customer emails that may need data-quality review
The CRM team wants to review customer email addresses that contain uppercase letters, leading/trailing spaces, or an unexpected format.
From customers, display customer_id, first_name, last_name, email, and a cleaned email value using LOWER and TRIM.
- Use LOWER(TRIM(email)) to produce a normalized email value.
- Use COALESCE to display 'Email Missing' for NULL email values.
- Return records where the original email differs from the normalized email, or the email is missing.
- Sort by customer ID ascending.
*/

SELECT
	customer_id,
    first_name,
    last_name,
    COALESCE(email, "Email Missing") AS customer_email,
    LOWER(TRIM(email)) AS customer_cleaned_email
FROM customers
WHERE email IS NULL
	OR email <> LOWER(TRIM(email))
ORDER BY customer_id ASC;