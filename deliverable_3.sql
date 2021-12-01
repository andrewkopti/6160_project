-- stored procedure to calculate ratings
DELIMITER //
DROP PROCEDURE IF EXISTS calculate_ratings;
CREATE PROCEDURE calculate_ratings ()
BEGIN
	SELECT d.driver_id as id,
	"driver" AS type,
    AVG(r.num_stars) AS rating
    FROM driver AS d
    JOIN `order` AS o
	ON o.driver_id = d.driver_id
	JOIN `rating` AS r
	ON r.rating_id = o.driver_rating
    GROUP BY d.driver_id
    UNION
    SELECT re.restaurant_id as id,
	"restaurant" AS type,
    AVG(r.num_stars) AS rating
    FROM restaurant AS re
    JOIN `order` AS o
	ON o.restaurant_id = re.restaurant_id
	JOIN `rating` AS r
	ON r.rating_id = o.restaurant_rating
    GROUP BY re.restaurant_id;
END//
DELIMITER ;

CALL calculate_ratings;

-- advanced view
CREATE OR REPLACE VIEW driver_rating_count AS
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

SELECT * FROM driver_rating_count;