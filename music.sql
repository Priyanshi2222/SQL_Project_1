-- EASY
-- 1. Who is the Senior most employee based on job title?
SELECT last_name, first_name, levels FROM employee
ORDER BY levels DESC 
LIMIT 1

-- 2, Which countries have the most invoices?
SELECT billing_country, COUNT(invoice_id) AS count FROM invoice 
GROUP BY billing_country 
ORDER BY count DESC
LIMIT 1

-- 3. What are the top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3
 
-- 4. Which city has the best customers? 
-- 	(Find the city that has highest sum of invoice totals, 
-- 	return both city name and sum of invoice totals)
SELECT billing_city, SUM(total) AS s FROM invoice
GROUP BY billing_city	
ORDER BY s DESC LIMIT 1

-- 5. Who is the best customer? 
-- (Find the customer who has spent the most amount of money)
SELECT I.customer_id, C.first_name, C.last_name, SUM(I.total) AS total FROM invoice I
JOIN customer C
ON I.customer_id = C.customer_id
GROUP BY I.customer_id,  C.first_name, C.last_name
ORDER BY total DESC
LIMIT 1


-- MEDIUM
-- 1. Write a query to return the email, first_name, last_name & genre of all rock music listeners.
-- (Rrturn your list ordered alphabetically by email starting with A)
SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track 
	JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
	)
ORDER BY email;

-- 2. Let's invite the artists who have written the most rock music in our dataset. Write a query
-- that returns the artist name and total track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs FROM artist 
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
WHERE track_id IN (SELECT track_id FROM track
	               JOIN genre ON track.genre_id = genre.genre_id
	               WHERE genre.name LIKE 'Rock')
GROUP BY artist.name, artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10

-- 3. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Millisecond for each track. Order by the song length with the longest
-- songs listed first.

SELECT name, milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) as avg_track_length 
	                  FROM track)
ORDER BY milliseconds DESC

-- ADVANCE:
-- 1.Find how much amount is spent by each customer on artists? Write a query to return  
-- customer name, artist name and total spent.
WITH best_selling_artist AS ( SELECT artist.artist_id AS artist_id,
	                           artist.name AS artist_name,
	                          SUM(invoice_line.unit_price*invoice_line.quantity)                            
	                          FROM invoice_line
	                          JOIN track ON track.track_id = invoice_line.track_id  
                              JOIN album ON album.album_id = track.album_id       
	                          JOIN artist ON artist.artist_id = album.artist_id
	                          GROUP BY 1
	                          ORDER BY 3 DESC
	                          LIMIT 1	)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il  ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb  ON t.album_id = alb.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC


-- 2. We want to find out the most popular music genre for each country. We determine the most popular genre with 
--    the highest amount of purchases. Write a query that returns each country along with the top genre. For countries 
-- 	where the maximum number of purchases is shared return all Genres. 


WITH popular_genre AS
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
           ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- 3.Write a query that determines the customer that has spent the most on music for each country. 
-- 	Write a query that returns the country along with the top customer and how much they spent. 
-- 	For countries where the top amount spent is shared, provide all customers who spent this amount. 

WITH customer_with_country AS (
	        SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending, 
	        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	        FROM invoice
	        JOIN customer ON customer.customer_id = invoice.customer_id
	        GROUP BY 1,2,3,4
	        ORDER BY 4 ASC, 5 DESC)
SELECT * FROM customer_with_country 
WHERE RowNo <= 1









