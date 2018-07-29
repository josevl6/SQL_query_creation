-- 1a. You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 
USE sakila;

SELECT actor.first_name, actor.last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor.actor_id, actor.first_name, actor.last_name  
FROM actor
WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor.first_name, actor.last_name  
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor.last_name, actor.first_name  
FROM actor
WHERE last_name LIKE '%LI%';

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
	ADD middle_name varchar(50) NOT NULL 
		AFTER first_name;
        
SELECT *
FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
describe actor;
ALTER TABLE actor
MODIFY middle_name BLOB;

describe actor;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP Column	middle_name;

-- SELECT *
-- FROM actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name,
COUNT(*) AS 'count_last_name'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,
COUNT(*) AS 'count_last_name'
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
-- SELECT * FROM actor
-- WHERE first_name = 'GROUCHO';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

SELECT * FROM actor
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

-- I had to uncheck the "safe updates" box in order to be able to update a record without specifying a primary key in the WHERE clause 
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address 
FROM staff INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
-- SELECT *
-- FROM payment;

SELECT s.first_name, s.last_name, SUM(p.amount) AS "Total amount rung up per staff member",p.payment_date
FROM staff s INNER JOIN payment p
ON s.staff_id = p.staff_id
GROUP BY p.staff_id
HAVING p.payment_date > "2005-07-31%" AND p.payment_date < "2005-09-01%";

HAVING p.payment_date between "2005-08-01%" and p.payment_date"2005-08-31%";
-- ?
-- HAVING p.payment_date > "2005-08-01%" and p.payment_date < "2005-09-01%"; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(fa.actor_id) AS "Number of Actors"
FROM film f INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id)
FROM film f INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT c.last_name, c.first_name, SUM(p.amount) AS "Total Amount Paid by Customer"
FROM customer c INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.last_name
ORDER BY c.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT f.title
FROM film f
WHERE f.language_id IN(	
	SELECT language_id FROM language
	WHERE name = "English")
AND f.title LIKE "K%" OR f.title LIKE "Q%";


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
-- I need to use ACTOR table, then film_actor, then film
SELECT a.first_name, a.last_name 
FROM actor a
WHERE actor_id IN(
	SELECT actor_id FROM film_actor
	WHERE film_id IN(
		SELECT film_id FROM film
		WHERE title = "Alone Trip")
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
-- all Canadian customers. Use joins to retrieve this information.
-- customer (address_id) to address to city (city_id), to country (country_id)

SELECT co.country, cu.first_name, cu.last_name, cu.email
FROM customer cu LEFT JOIN address a
ON cu.address_id = a.address_id 
	LEFT JOIN city c
	ON a.city_id = c.city_id
		LEFT JOIN country co
		ON c.country_id = co.country_id
		WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

-- Use the tables (category, film, film_category) OR use the VIEW (film_list)

-- SELECT category, title, count(title) AS "count"
-- FROM film_list
-- WHERE category = "Family";

SELECT category, title
FROM film_list
WHERE category = "Family";

-- OR

SELECT title
FROM film
WHERE film_id IN(
	SELECT film_id FROM film_category
	WHERE category_id IN(
		SELECT category_id FROM category ca
		WHERE name = "Family"));

-- OR

SELECT ca.name, f.title
FROM film f LEFT JOIN film_category fc
ON f.film_id =  fc.film_id
	LEFT JOIN category ca
    ON fc.category_id = ca.category_id
    WHERE ca.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
-- Use tables: inventory, 

SELECT f.film_id, f.title, count(r.inventory_id) AS "# of times rented"
FROM rental r
LEFT OUTER JOIN inventory i
ON r.inventory_id = i.inventory_id
LEFT OUTER JOIN film_text f
ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY count(r.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- Columns: store(store_id), payment(amount)
-- USE the following tables: store, payment, and staff 

SELECT s.store_id, SUM(p.amount) AS "Total Revenue by Store"
FROM store s LEFT OUTER JOIN staff st
ON s.store_id = st.store_id
LEFT OUTER JOIN payment p
ON st.staff_id = p.staff_id
GROUP BY s.store_id
-- ORDER BY SUM(p.amount) DESC
;

-- 7g. Write a query to display for each store its store ID, city, and country.

-- SHOW columns: store ID(table:store), city(table: city), and country (table: country)
-- Use tables: store(store_id and address_id), address (address_id and city_id), city(city_id and country_id), 
-- and country(country_id and country)

SELECT s.store_id AS "Store ID", ct.city AS "City", cnt.country AS "Country"
FROM store s INNER JOIN address a
ON s.address_id = a.address_id
INNER JOIN city ct
ON a.city_id = ct.city_id
INNER JOIN country cnt
ON ct.country_id = cnt.country_id
ORDER BY cnt.country ASC;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.


-- 8b. How would you display the view that you created in 8a?
select * from top_five_grossing_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_grossing_genres;