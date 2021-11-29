CREATE VIEW driver_ratings AS

WITH cte AS (
SELECT d.driver_id AS driver_id,
	r.rating_id AS rating_id,
    r.num_stars AS num_stars
FROM driver AS d
JOIN `order` AS o
ON o.driver_id = d.driver_id
JOIN `rating` AS r
ON r.rating_id = o.driver_rating)

SELECT driver_id,
	AVG(num_stars) AS avg_rating,
    COUNT(rating_id) AS total_ratings,
    (SELECT COUNT(*)
    FROM cte AS c
    WHERE num_stars > 3 AND c.driver_id = cte.driver_id) AS positive_ratings,
    (SELECT COUNT(*)
    FROM cte AS c
    WHERE num_stars = 3 AND c.driver_id = cte.driver_id) AS neutral_ratings,
    (SELECT COUNT(*)
    FROM cte AS c
    WHERE num_stars < 3 AND c.driver_id = cte.driver_id) AS negative_ratings
FROM cte
GROUP BY driver_id
ORDER BY avg_rating;

SELECT * FROM driver_ratings;