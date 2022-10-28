<root>: mysql

show variables like '%dir%';

create database bank;

<root>: mysql -u root -p bank

SHOW DATABASES;
-- use bank
use sakila;

-- SOURCE /var/lib/mysql/LearningSQLExample.sql;
SOURCE /var/lib/mysql/sakila-db/sakila-schema.sql
SOURCE /var/lib/mysql/sakila-db/sakila-data.sql

#########################################
######  Create and modify tables. #######
#########################################

CREATE TABLE person
(person_id SMALLINT UNSIGNED,
fname VARCHAR(20),
lname VARCHAR(20),
gender ENUM('M','F'),
birth_date DATE,
street VARCHAR(30),
city VARCHAR(20),
state VARCHAR(20),
country VARCHAR(20),
postal_code VARCHAR(20),
CONSTRAINT pk_person PRIMARY KEY (person_id)
);

DESC person;

CREATE TABLE favorite_food
(person_id SMALLINT UNSIGNED,
food VARCHAR(20),
CONSTRAINT pk_favorite_food PRIMARY KEY (person_id, food),
CONSTRAINT fk_fav_food_person_id FOREIGN KEY (person_id)
REFERENCES person (person_id)
);

INSERT INTO person (person_id, fname, lname, gender, birth_date)
VALUES (1, 'William', 'Turner', 'M', '1972-05-27');

INSERT INTO favorite_food (person_id, food) VALUES (1, 'pizza');

SELECT * FROM favorite_food

INSERT INTO person
(person_id, fname, lname, gender, birth_date,
street , city , state , country , postal_code )
VALUES(2, 'Susan', 'Smith', 'F', '1975-11-02',
'23 Maple St.', 'Arlington', 'VA', 'USA', '20220');

UPDATE person
SET street ='1225 Tremont St.',
city='Boston',
state='MA',
country='USA',
postal_code ='02138'
WHERE person_id=1;

DELETE FROM person WHERE person_id=2;

DROP TABLE favorite_food;
DROP TABLE person;

SHOW TABLES;
DESC customer;

#########################################
############  Query tables  #############
#########################################

SELECT emp_id
'ACTIVE',
emp_id * 3.14159,
UPPER (lname)
FROM employee;

SELECT VERSION(), USER(), DATABASE();

SELECT emp_id,
'ACTIVE' AS status,
emp_id * 3.14159 AS empid_x_pi,
UPPER(lname) AS last_name_upper
FROM employee;

SELECT cust_id FROM account;
SELECT DISTINCT cust_id FROM account;

SELECT e.emp_id, e.fname, e.lname
FROM (SELECT emp_id, fname, lname, start_date, title 
    FROM employee) AS e;

CREATE VIEW employee_vw AS
SELECT emp_id, fname, lname,
YEAR(start_date) AS start_year
FROM employee;

SELECT emp_id , start_year
FROM employee_vw;

SELECT e.emp_id, e.fname, e.lname, d.name AS dept_name
FROM employee AS e INNER JOIN department AS d
ON e.dept_id=d.dept_id;

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE title='Head Teller';

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE title='Head Teller' AND start_date > '2002-01-01';

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE title='Head Teller' OR start_date > '2002-01-01';

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE NOT (title != 'Head Teller') AND start_date >= '2002-01-01';

SELECT emp_id, fname, lname, start_date, title
FROM employee
WHERE (title='Head Teller' AND start_date > '2002-01-01')
OR (title='Teller' AND start_date > '2003-01-01');

SELECT d.name, COUNT(e.emp_id) AS num_employees
FROM department AS d INNER JOIN employee AS e
ON d.dept_id=e.dept_id
GROUP BY d.name
HAVING COUNT(e.emp_id) > 2;

SELECT open_emp_id, product_cd
FROM account
ORDER BY open_emp_id;

SELECT open_emp_id, product_cd
FROM account
ORDER BY open_emp_id DESC;

SELECT cust_id, cust_type_cd, city, state, fed_id
FROM customer
ORDER BY RIGHT(fed_id, 3);

SELECT emp_id, title, start_date, fname, lname
FROM employee
ORDER BY 2,5;


###################################
##########  Filtering  ############
###################################

SELECT pt.name AS product_type, p.name AS product
FROM product AS p INNER JOIN product_type AS pt
ON p.product_type_cd = pt.product_type_cd
WHERE pt.name = 'customer accounts';

SELECT pt.name AS product_type, p.name AS product
FROM product AS p INNER JOIN product_type AS pt
ON p.product_type_cd = pt.product_type_cd
WHERE pt.name != 'customer accounts';

DELETE FROM account
WHERE status = "CLOSED" AND YEAR(close_date)=2002;

# the two below are identical
SELECT account_id , product_cd , cust_id , avail_balance
FROM account
WHERE avail_balance BETWEEN 3000 AND 5000;

SELECT account_id , product_cd , cust_id , avail_balance
FROM account
WHERE avail_balance >= 3000 AND avail_balance <= 5000;

SELECT account_id , product_cd, cust_id , avail_balance
FROM account
WHERE product_cd IN ('CHK', 'SAV', 'CD', 'MM');

SELECT account_id , product_cd, cust_id , avail_balance
FROM account
WHERE product_cd NOT IN ('CHK', 'SAV', 'CD', 'MM');

SELECT account_id , product_cd, cust_id , avail_balance
FROM account
WHERE product_cd IN (SELECT product_cd FROM product 
WHERE product_type_cd = 'ACCOUNT');

# the two below are identical
SELECT emp_id , fname, lname
FROM employee
WHERE LEFT (lname, 1 ) = 'T';

SELECT emp_id , fname, lname
FROM employee
WHERE lname LIKE 'T%';
# wildcard 通配符 P67 in Learning SQL 2nd edition

SELECT emp_id , fname, lname
FROM employee
WHERE lname REGEXP '^[FG]';

SELECT emp_id , fname , lname , superior_emp_id
FROM employee
WHERE superior_emp_id IS NULL;

SELECT emp_id , fname , lname , superior_emp_id
FROM employee
WHERE superior_emp_id != 6 OR superior_emp_id IS NULL;

###################################################
#############  Query multiple tables  #############
##  Start to use "sakila" database by Edition 3  ##
## previous codes are bank database by Edition 2 ##
###################################################
------------------------------------
-----------  INNER JOIN  -----------
-----------  CROSS JOIN  -----------
------------------------------------
## INNER JOIN and CROSS JOIN and JOIN are same in mysql,
## returns Cartesian Product of table1 and table2.

-- table1:      table2:
--   a b            e f
-- c 1 2          g 5 6
-- d 3 4          h 7 8

-- SELECT * FROM table1 INNER JOIN table2;
--   a b e f
--   1 2 5 6
--   1 2 7 8
--   3 4 5 6
--   3 4 7 8
------------------------------------
------------------------------------

SELECT c.first_name, c.last_name, a.address
FROM customer AS c INNER JOIN address AS a
ON c.address_id = a.address_id;

SELECT c.first_name, c.last_name, ct.city
FROM customer AS c INNER JOIN address AS a
ON c.address_id=a.address_id
INNER JOIN city AS ct
ON a.city_id=ct.city_id;

SELECT c.first_name, c.last_name, addr.address, addr.city
FROM customer AS c INNER JOIN
(SELECT a.address_id, a.address, ct.city
FROM address AS a INNER JOIN city AS ct
ON a.city_id=ct.city_id
WHERE a.district='California') AS addr
ON c.address_id=addr.address_id;

SELECT f.title
FROM film AS f INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
INNER JOIN actor AS a
ON fa.actor_id = a.actor_id
WHERE ((a.first_name='CATE' AND a.last_name='MCQUEEN')
OR (a.first_name='CUBA' AND a.last_name='BIRCH'));

SELECT f.title,
a1.first_name, a1.last_name,
a2.first_name, a2.last_name
FROM film AS f INNER JOIN film_actor AS fa1
ON f.film_id = fa1.film_id
INNER JOIN actor AS a1
ON fa1.actor_id = a1.actor_id
INNER JOIN film_actor AS fa2
ON f.film_id = fa2.film_id
INNER JOIN actor AS a2
ON fa2.actor_id = a2.actor_id
WHERE (a1.first_name = 'CATE' AND a1.last_name = 'MCQUEEN')
AND (a2.first_name = 'CUBA' AND a2.last_name = 'BIRCH');

SELECT f.title , a.first_name, a.last_name
FROM film AS f INNER JOIN film_actor AS fa
ON f.film_id=fa.film_id
INNER JOIN actor AS a
ON fa.actor_id=a.actor_id
WHERE a.first_name='john';

###################################
#############  Sets  ##############
###################################

-- UNION    : sorts combined set and removes duplicates
-- UNION ALL: does not

SELECT 'CUST' AS typ, c.first_name, c.last_name
FROM customer AS c
UNION ALL
SELECT 'ACTR' AS typ, a.first_name, a.last_name
FROM actor AS a;

SELECT c.first_name, c.last_name
FROM customer AS c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION ALL
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

SELECT c.first_name, c.last_name
FROM customer AS c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
UNION
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%';

SELECT a.first_name AS fname, a.last_name AS lname
FROM actor AS a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
UNION ALL
SELECT c.first_name, c.last_name
FROM customer AS c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%'
ORDER BY lname, fname;

SELECT a.first_name AS fname, a.last_name AS lname
FROM actor AS a
WHERE a.first_name LIKE 'J%' AND a.last_name LIKE 'D%'
UNION ALL
SELECT c.first_name, c.last_name
FROM customer AS c
WHERE c.first_name LIKE 'M%' AND c.last_name LIKE 'T%'
UNION
SELECT c.first_name, c.last_name
FROM customer AS c
WHERE c.first_name LIKE 'J%' AND c.last_name LIKE 'D%';

#####################################################
##### Data Generation, Manipulation, Conversion #####
#####################################################

-- pass

#####################################
#####  Grouping and Aggregates  #####
#####################################

# number of rows
SELECT COUNT(*) FROM payment;

# number of colums
SELECT COUNT(*)
FROM information_schema.columns
WHERE table_schema='sakila' AND table_name='language';

SELECT customer_id, COUNT(*)
FROM rental
GROUP BY customer_id
HAVING COUNT(*) >= 40
ORDER BY 2 DESC
LIMIT 5;

# HAVING: group filter conditions

# Aggregate Functions
MAX()
MIN()
AVG()
SUM()
COUNT()
# Aggregate Functions

SELECT customer_id,
MAX(amount) AS max_amt,
MIN(amount) AS min_amt,
AVG(amount) AS avg_amt,
SUM(amount) AS tot_amt,
COUNT(*) AS num_payments
FROM payment
GROUP BY customer_id
ORDER BY tot_amt DESC
LIMIT 5;

SELECT COUNT(customer_id) AS num_rows,
COUNT(DISTINCT customer_id) AS num_customers
FROM payment;

SELECT MAX(datediff(return_date, rental_date))
FROM rental;

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor AS fa INNER JOIN film AS f
ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating
ORDER BY 1,2;

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor AS fa INNER JOIN film AS f
ON fa.film_id = f.film_id
GROUP BY fa.actor_id, f.rating
WITH ROLLUP
ORDER BY 1,2;

SELECT fa.actor_id, f.rating, COUNT(*)
FROM film_actor AS fa INNER JOIN film AS f
ON fa.film_id = f.film_id
WHERE f.rating IN ('G','PG')
GROUP BY fa.actor_id, f.rating
HAVING COUNT(*)>9;

SELECT extract(YEAR FROM rental_date) AS year,
COUNT(*) AS how_many
FROM rental 
GROUP BY extract(YEAR FROM rental_date);


###################################
#########   Subqueries   ##########
###################################

## Noncorrelated Subqueries
## mostly used

SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id = 
(SELECT MAX(customer_id) FROM customer);

SELECT city_id, city
FROM city
WHERE country_id NOT IN
(SELECT country_id
FROM country
WHERE country IN ('Canada', 'Mexico'));
-- These two query are identical.
SELECT city_id, city
FROM city
WHERE country_id != ALL
(SELECT country_id
FROM country
WHERE country = 'Canada' OR country = 'Mexico');

SELECT customer_id, COUNT(*)
FROM rental
GROUP BY customer_id
HAVING COUNT(*) > ALL
(SELECT COUNT(*)
    FROM rental AS r
    INNER JOIN customer AS c
    ON r.customer_id = c.customer_id
    INNER JOIN address AS a
    ON c.address_id = a.address_id
    INNER JOIN city AS ct
    ON a.city_id = ct.city_id
    INNER JOIN country AS co
    ON ct.country_id = co.country_id
    WHERE co.country IN ('United States', 'Mexico', 'Canada')
    GROUP BY r.customer_id
);

SELECT customer_id, sum(amount)
FROM payment
GROUP BY customer_id
HAVING sum(amount) > ANY
(SELECT sum(p.amount)
    FROM payment AS p
    INNER JOIN customer AS c
    ON p.customer_id = c.customer_id
    INNER JOIN address AS a
    ON c.address_id = a.address_id
    INNER JOIN city AS ct
    On a.city_id = ct.city_id
    INNER JOIN country AS co
    ON ct.country_id = co.country_id
    WHERE co.country IN ('Bolivia','Paraguay','Chile')
    GROUP BY co.country
);

SELECT fa.actor_id, fa.film_id
FROM film_actor AS fa
WHERE fa.actor_id IN
(SELECT actor_id FROM actor WHERE last_name='MONROE')
AND fa.film_id IN
(SELECT film_id FROM film WHERE rating='PG');
-- These two query are identical.
SELECT actor_id, film_id
FROM film_actor
WHERE (actor_id, film_id) IN
(SELECT a.actor_id, f.film_id
FROM actor AS a
CROSS JOIN film AS f
WHERE a.last_name='MONROE'
AND f.rating='PG');


## Correlated Subqueries

SELECT c.first_name, c.last_name
FROM customer AS c
WHERE 20=
(SELECT count(*) FROM rental AS r
WHERE r.customer_id=c.customer_id);
-- These two query are identical.
SELECT c.first_name, c.last_name
FROM customer AS c
WHERE 
(SELECT count(*) FROM rental AS r
WHERE r.customer_id=c.customer_id)
=20;

SELECT c.first_name, c.last_name
FROM customer AS c
WHERE
(SELECT sum(p.amount) 
FROM payment AS p
WHERE p.customer_id=c.customer_id)
BETWEEN 180 AND 240;

SELECT c.first_name, c.last_name
FROM customer AS c
WHERE EXISTS
(SELECT 1 FROM rental AS r
WHERE r.customer_id = c.customer_id
AND date(r.rental_date) < '2005-05-25');

SELECT a.first_name, a.last_name
FROM actor AS a
WHERE NOT EXISTS
(SELECT 1 
FROM film_actor AS fa
INNER JOIN film AS f 
ON f.film_id = fa.film_id
WHERE fa.actor_id = a.actor_id
AND f.rating = 'R');

## Data Manipulation Using Correlated Subqueries
-- pass

SELECT c.first_name, c.last_name, 
pymnt.num_rentals, pymnt.tot_payments
FROM customer AS c
INNER JOIN
(SELECT customer_id,
count(*) AS num_rentals, sum(amount) AS tot_payments
FROM payment
GROUP BY customer_id
) AS pymnt
ON c.customer_id = pymnt.customer_id;

SELECT pymnt_grps.name, count(*) AS num_customers
FROM 
(SELECT customer_id,
count(*) AS num_rentals, sum(amount) AS tot_payments
FROM payment
GROUP BY customer_id
) AS pymnt
INNER JOIN
(SELECT 'Small Fry' AS name, 0 AS low_limit, 74.99 AS high_limit
UNION ALL
SELECT 'Average Joes' AS name, 75 AS low_limit, 149.99 high_limit
UNION ALL
SELECT 'Heavy Hitters' AS name, 150 AS low_limit, 
9999999.99 AS high_limit
) AS pymnt_grps
ON pymnt.tot_payments
BETWEEN pymnt_grps.low_limit AND pymnt_grps.high_limit
GROUP BY pymnt_grps.name;

SELECT c.first_name, c.last_name, ct.city,
sum(p.amount) AS tot_payments, COUNT(*) AS tot_rentals
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
INNER JOIN address AS a
ON c.address_id = a.address_id
INNER JOIN city AS ct
ON a.city_id = ct.city_id
GROUP BY c.first_name, c.last_name, ct.city;
-- These 3 query are identical.
SELECT c.first_name, c.last_name, ct.city,
pymnt.tot_payments, pymnt.tot_rentals
FROM
(SELECT customer_id,
count(*) AS tot_rentals, sum(amount) AS tot_payments
FROM payment
GROUP BY customer_id
) AS pymnt
INNER JOIN customer AS c
ON pymnt.customer_id = c.customer_id
INNER JOIN address AS a
ON c.address_id = a.address_id
INNER JOIN city AS ct
ON a.city_id = ct.city_id;
-- These 3 query are identical.
SELECT
(SELECT c.first_name FROM customer AS c
WHERE c.customer_id = p.customer_id
) AS first_name,
(SELECT c.last_name FROM customer AS c
WHERE c.customer_id = p.customer_id
) AS last_name,
(SELECT ct.city
FROM customer AS c
INNER JOIN address AS a 
ON c.address_id = a.address_id
INNER JOIN city AS ct
ON a.city_id = ct.city_id
WHERE c.customer_id = p.customer_id
) AS city,
sum(p.amount) AS tot_payments,
count(*) AS tot_rentals
FROM payment AS p
GROUP BY p.customer_id;

WITH actor_s AS
(SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name Like 'S%'),
actor_s_pg AS
(SELECT s.actor_id, s.first_name, s.last_name, 
f.film_id, f.title
FROM actor_s AS s
INNER JOIN film_actor AS fa
ON s.actor_id = fa.actor_id
INNER JOIN film AS f
ON f.film_id = fa.film_id
WHERE f.rating = 'PG'),
actors_s_pg_revenue AS
(SELECT spg.first_name, spg.last_name, p.amount
FROM actor_s_pg AS spg
INNER JOIN inventory AS i
ON i.film_id = spg.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
ON r.rental_id = p.rental_id) -- end of WITH
SELECT spg_rev.first_name, spg_rev.last_name,
sum(spg_rev.amount) AS tot_revenue
FROM actors_s_pg_revenue AS spg_rev
GROUP BY spg_rev.first_name, spg_rev.last_name
ORDER BY 3 desc;
-- This is wrong.↓
--     WITH 
--     (SELECT actor_id, first_name, last_name
--     FROM actor
--     WHERE last_name Like 'S%'
--     ) AS actor_s,
--     ...

SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
ORDER BY
(SELECT count(*) FROM film_actor AS fa
WHERE fa.actor_id = a.actor_id) DESC;








###################################
############   Join   #############
###################################



































