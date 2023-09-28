/* We want to understand more about the movies that families are watching. 
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

/* Query 1: Query used for first insight */
 SELECT f.title,
       c.name,
       COUNT(r.rental_id) AS rental_count
  FROM category AS c
       JOIN film_category AS fc
        ON c.category_id = fc.category_id
        AND c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')

       JOIN film AS f
        ON f.film_id = fc.film_id

       JOIN inventory AS i
        ON f.film_id = i.film_id

       JOIN rental AS r
        ON i.inventory_id = r.inventory_id
 GROUP BY 1, 2
 ORDER BY 2, 1;

/* Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category.
 The resulting table should have three columns: Category, Rental length category, Count */

/* Query 2: Query used for second insight */
 WITH main AS ( 
	       SELECT f.title AS film_title, 
                      c.name AS category_name,
	              f.rental_duration,
	              NTILE(4) OVER(ORDER BY rental_duration) AS standard_quartile
               FROM film f
               JOIN film_category fc ON f.film_id = fc.film_id
               JOIN category c ON c.category_id = fc.category_id
               AND c.name IN ('Animation','Children','Classics','Comedy','Family','Music') 
             )

SELECT category_name,
       standard_quartile,
       COUNT(film_title)
FROM main
GROUP BY 1,2
ORDER BY 1,2

/* We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for.
Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month.
Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month. */

/* Query 3: Query used for third insight */
 SELECT DATE_PART('month', r.rental_date) AS rental_month, 
       DATE_PART('year', r.rental_date) AS rental_year,
       ('Store ' || sr.store_id) AS store_id,
       COUNT(*)
  FROM store AS sr
       JOIN staff AS st
        ON sr.store_id = st.store_id
		
       JOIN rental r
        ON st.staff_id = r.staff_id
 GROUP BY 1, 2, 3
 ORDER BY 2, 1;

/* Finally, for each of these top 10 paying customers, I would like to find out the difference across their monthly payments during 2007. 
Please go ahead and write a query to compare the payment amounts in each successive month. 
Repeat this for each of these 10 paying customers. Also, it will be tremendously helpful if you can identify the customer name who paid the most difference in terms of payments. */

/* Query 4: Query used for fourth insight */
 WITH t1 AS (SELECT (first_name || ' ' || last_name) AS name, 
                   c.customer_id, 
                   p.amount, 
                   p.payment_date
              FROM customer AS c
                   JOIN payment AS p
                    ON c.customer_id = p.customer_id),

     t2 AS (SELECT t1.customer_id
              FROM t1
             GROUP BY 1
             ORDER BY SUM(t1.amount) DESC
             LIMIT 10)

SELECT t1.name,
       DATE_PART('month', t1.payment_date) AS payment_month, 
       DATE_PART('year', t1.payment_date) AS payment_year,
       COUNT (*) AS payment_count_per_month ,
       SUM(t1.amount) AS total_pay_amount
  FROM t1
       JOIN t2
        ON t1.customer_id = t2.customer_id
 WHERE t1.payment_date BETWEEN '20070101' AND '20080101'
 GROUP BY 1, 2, 3;