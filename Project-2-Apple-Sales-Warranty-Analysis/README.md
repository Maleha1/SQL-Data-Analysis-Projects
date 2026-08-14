# Apple Sales & Warranty Analysis Using SQL

## Overview

A SQL data analysis project focused on analyzing Apple sales, stores, products, and warranty claims.

The project explores sales performance, store performance, product pricing, warranty activity, sales growth, and product lifecycle trends using multiple SQL techniques.

## Dataset

The analysis uses four main tables:

- `AppleSales`
- `stores`
- `products`
- `category`
- `warranty`

## Store & Sales Analysis

The project includes analysis of:

- Number of stores in each country
- Total units sold by each store
- Number of sales in December 2023
- Store with the highest units sold during the last year
- Best-selling day for each store
- Monthly sales performance in the United States
- Year-by-year sales growth for each store
- Monthly running sales totals for each store

## Product Analysis

Product data was analyzed to understand pricing, sales, and product performance.

The analysis includes:

- Number of unique products sold
- Average product price by category
- Least-selling product in each country for each year
- Product sales trends over time
- Product lifecycle analysis based on time since launch

Product lifecycle stages were categorized into:

- Launch Phase
- Early Maturity
- Peak / Plateau
- Long Tail

## Warranty Analysis

The project analyzes warranty claims and repair statuses, including:

- Stores with no warranty claims
- Warranty claims filed in 2020 and 2024
- Warranty claims filed within 180 days of a sale
- Warranty claims for recently launched products
- Product categories with the most warranty claims
- Warranty claim percentage by country
- Store with the highest percentage of completed claims

Some requested statuses were not available in the dataset. Therefore:

- `Rejected` was used instead of `Warranty Void`
- `Completed` was used as the closest available equivalent to `Paid Repaired`

## Sales & Warranty Relationships

The analysis also explores relationships between sales, product prices, and warranty claims.

This includes:

- Warranty claims by product price range
- Warranty claim percentage after purchases by country
- Warranty activity for products sold during recent periods

Products were grouped into price ranges:

- Cheap
- Medium
- Expensive

## Advanced SQL Analysis

The project uses SQL techniques to perform more advanced analysis, including:

- Common Table Expressions (CTEs)
- Window functions
- `ROW_NUMBER()`
- `RANK()`
- `LAG()`
- Running totals
- `DATEADD()`
- `DATEDIFF()`
- Date-based filtering
- Conditional logic using `CASE`
- Aggregation and grouping

## SQL Techniques Used

- `SELECT`
- `TOP`
- `WHERE`
- `GROUP BY`
- `ORDER BY`
- `HAVING`
- `JOIN`
- `LEFT JOIN`
- `COUNT`
- `COUNT(DISTINCT)`
- `SUM`
- `AVG`
- `CASE`
- `YEAR()`
- `MONTH()`
- `DATEADD()`
- `DATEDIFF()`
- CTEs
- Window Functions
- `ROW_NUMBER()`
- `RANK()`
- `LAG()`

## Project Objectives

- Analyze sales performance across stores and countries
- Identify high-performing and low-performing products
- Analyze warranty claim activity
- Examine warranty claims by product category and price range
- Calculate store-level sales growth
- Analyze monthly running sales totals
- Explore product sales across different lifecycle stages
- Practice SQL joins, aggregations, CTEs, and window functions
