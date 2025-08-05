# Bazario Database Model - Learning Exercises

This guide provides an overview of the Bazario marketplace database structure and practical SQL exercises to help you understand how the system works.

## Database Schema Overview

The Bazario marketplace uses the following key tables:

1. **ROLES** - Defines user roles (Admin, Seller, Buyer)
2. **USERS** - Stores user account information
3. **USERS_OTP_STORE** - Manages OTP authentication
4. **USER_SESSION_AUDIT** - Tracks user login/logout activity
5. **ITEMS_STORE** - Contains product categories
6. **SELLERS_REQUESTS** - Stores seller listings/offerings
7. **SELLER_BUYER_LINEAGE_REQUESTS** - Records buyer bids and transactions

## Schema Visualization

```
ROLES (1) ------ (N) USERS (1) ------ (N) USER_SESSION_AUDIT
                    |
                    | (1)
                    |
                    ∨ (N)
              USERS_OTP_STORE

USERS (1) ------ (N) SELLERS_REQUESTS (1) ------ (N) SELLER_BUYER_LINEAGE_REQUESTS (N) ------ (1) USERS
                      |
                      | (N)
                      |
                      ∨ (1)
                    ITEMS_STORE
```

## Understanding Key Relationships

- Each user has exactly one role (Admin, Seller, or Buyer)
- A seller can create multiple product listings
- Each listing belongs to one product category
- Buyers can place bids on multiple listings
- Each bid is connected to one buyer and one listing
- OTP records are linked to specific users
- Session audits track user login activities

## SQL Learning Exercises

Try to solve these exercises to enhance your understanding of the Bazario database structure. The exercises are grouped by difficulty level.

### Basic Exercises

**Exercise 1:** Count the total number of users by role.

**Exercise 2:** Find all active seller listings that are still open (not closed).

**Exercise 3:** List all product categories along with the number of current listings in each category.

**Exercise 4:** Find users who haven't logged in for the past 7 days.

**Exercise 5:** Find the average price of listings by category.

### Intermediate Exercises

**Exercise 6:** Find sellers who have the most number of open listings.

**Exercise 7:** Calculate the acceptance rate of bids for each seller (number of accepted bids / total bids).

**Exercise 8:** Find all buyers who have successfully bid on at least 3 different items.

**Exercise 9:** Identify listings that have received bids but no accepted bids yet.

**Exercise 10:** Calculate the average difference between the asking price and the final agreed price for completed transactions.

### Advanced Exercises

**Exercise 11:** Create a dashboard query that shows:

- Total active listings
- Total completed transactions in the last 30 days
- Total value of all completed transactions
- Average time between listing creation and transaction completion

**Exercise 12:** Find "power sellers" who have:

- At least 5 listings
- An acceptance rate over 70%
- An average rating above 4.5 (assuming a rating column exists)

**Exercise 13:** Write a query to identify potential fraudulent activities:

- Users with multiple failed OTP attempts
- Unusual login patterns (multiple logins from different locations)
- Unusually high or low bid prices compared to the average for similar items

**Exercise 14:** Create a recommendation system query that suggests listings to buyers based on their past bidding history and item categories.

**Exercise 15:** Design a query to implement a search feature allowing users to search listings by keyword in the description, filter by price range, category, and location.

## Sample Solutions

Here are solutions to some of the exercises to help you get started:

### Solution to Exercise 1

```sql
SELECT r.role_name, COUNT(u.id) as user_count
FROM USERS u
JOIN ROLES r ON u.role_id = r.id
GROUP BY r.role_name
ORDER BY user_count DESC;
```

### Solution to Exercise 3

```sql
SELECT i.item_type, COUNT(sr.id) as listing_count
FROM ITEMS_STORE i
LEFT JOIN SELLERS_REQUESTS sr ON i.id = sr.item_id AND sr.is_closed = FALSE
GROUP BY i.item_type
ORDER BY listing_count DESC;
```

## Additional Challenges

1. **Database Optimization:** Review the current schema and suggest any indexes that might improve query performance.

2. **Schema Extension:** Design additional tables to support a new feature such as:
   - User ratings and reviews
   - Payment processing
   - Messaging between buyers and sellers

3. **Data Analysis:** Write queries to analyze marketplace trends:
   - Busiest days of the week for new listings
   - Most popular item categories by region
   - Price fluctuations over time for specific categories

## Tips for Writing Efficient SQL Queries

1. Always use specific columns in your SELECT statement instead of SELECT *
2. Use appropriate JOINs (INNER, LEFT, RIGHT) based on your requirements
3. Add indexes to frequently queried columns
4. Use WHERE conditions before GROUP BY to reduce the amount of data processed
5. Be careful with subqueries as they can impact performance
6. Use EXPLAIN to analyze query execution plans

Good luck with the exercises! These problems will help you understand the Bazario marketplace data model and improve your SQL skills.