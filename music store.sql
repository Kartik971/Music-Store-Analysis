-- easy questions

-- 1) who is the senior most employee based on the Job title?
select * from employee 
order by levels desc
limit 1;
-- andrew (general manager)

-- 2) which country has most invoices?
select count(billing_country) as no_of_orders,billing_country from invoice
group by billing_country
order by no_of_orders desc;
-- USA 131

-- 3) what are top 3 values in total invoices?

select * from invoice
order by total desc
limit 3;

-- 4) which city has the best customers ?we would like to throw a promotional music festival
-- in the city we made the most money.Write a query that returns one city that has the highest 
-- sum of invoice totals.returns boththe city name and sum of invoice totals

select billing_city ,sum(total) as sum_total from invoice
group by billing_city
order by sum_total  desc; 
-- prague,mountainview,london

-- who is the best customer ? the customer who spent the most money will be declared the best 
-- best customer ?write a query who spent the most money?

select customer.customer_id ,customer.first_name,customer.last_name,sum(invoice.total) as total
from customer
join invoice    -- default inner join
on customer.customer_id = invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total desc
limit 1;
-- 'FrantiÅ¡ek' WichterlovÃ¡


-- moderate

-- 1) write a query to return the email,firstname,last name,& genre of all rockmusic listeners
-- return yoour list ordered alphabetically by email starting with A

select first_name,last_name ,email from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where invoice_line.track_id in(
select track.track_id from track
join genre on track.genre_id=track.genre_id
where genre.name like "Rock"
)
order by email;

-- method 2
SELECT DISTINCT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY customer.email;


-- 2)lets invite the artists who have written the mock rock music in our dataset.
-- write query that returns the artist name and total track count of top 10 rock bands.

select artist.artist_id,artist.name,count(artist.artist_id) as no_of_songs from track
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name="Rock"
group by artist.artist_id,artist.name
order by no_of_songs desc
limit 10;

-- 3) Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest
 -- songs listed first
 
 select track.name,track.milliseconds from track
 where milliseconds > (select avg(milliseconds) as average from track)
 order by track.milliseconds desc;
 
 
 -- Hard
 
 -- /* Q1: Find how much amount spent by each customer on artists? Write a query to return
 -- customer name, artist name and total spent */
 
 
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1,2
	ORDER BY 3 DESC

)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- method2 

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice i
JOIN 
    customer c ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album2 alb ON alb.album_id = t.album_id
JOIN 
    (
        SELECT 
            artist.artist_id AS artist_id, 
            artist.name AS artist_name, 
            SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
        FROM 
            invoice_line
        JOIN 
            track ON track.track_id = invoice_line.track_id
        JOIN 
            album2 ON album2.album_id = track.album_id
        JOIN 
            artist ON artist.artist_id = album2.artist_id
        GROUP BY 
            artist.artist_id, artist.name
        ORDER BY 
            total_sales DESC
    ) bsa 
ON 
    bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name
ORDER BY 
    amount_spent DESC;
    
    
    
    /* Q2: We want to find out the most popular music Genre for each country. We determine
    the most popular genre as the genre with the highest amount of purchases. Write a query
    that returns each country along with the top Genre. For countries where the maximum number
    of purchases is shared return all Genres. */
 
 with popular_genre as(
 select count(invoice_line.quantity) as purchases,genre.name,genre.genre_id,customer.country,
 row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) 
 as row_no from invoice_line
 join invoice on invoice_line.invoice_id=invoice.invoice_id
 join customer on invoice.customer_id=customer.customer_id
 join track on track.track_id=invoice_line.track_id
 join genre on genre.genre_id=track.track_id
 group by 2 ,3,4
 order by 1 desc
 )
 select *from popular_genre where row_no <2;
 
 
 
/* Q3: Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how much 
they spent. For countries where the top amount spent is shared, provide all customers who 
spent this amount. */
 
 with best_cust_each_country as (
 select customer.customer_id,customer.first_name,customer.last_name,customer.country,
 sum(invoice_line.unit_price*quantity) as total_spent,
 row_number() over (partition by customer.country order by sum(invoice_line.unit_price*quantity)  desc)
 as row_no from customer
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice_line.invoice_id=invoice.invoice_id
 group by 1,2,3,4
 order by total_spent desc)
 select* from best_cust_each_country where row_no < 2;
 
 
 
 -- method 2
 
 WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;
 
 -- method 3
 
  select * from (
 select customer.customer_id,customer.first_name,customer.last_name,customer.country,
 sum(invoice_line.unit_price*quantity) as total_spent,
 row_number() over (partition by customer.country order by sum(invoice_line.unit_price*quantity)  desc)
 as row_no from customer
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice_line.invoice_id=invoice.invoice_id
 group by 1,2,3,4
 order by total_spent desc) best
 where row_no<2;