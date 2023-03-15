-- main table
-- first query
-- get cost of each trip by converting trip duration by cost rate

SELECT *,
	CASE
		-- member cost breakdown
		WHEN t1.member_casual LIKE 'member' THEN
			CASE
				WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min >= 55
					THEN (2 + (t1.duration_min * 0.20))::NUMERIC::MONEY
				WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min > 45 AND t1.duration_min < 55
					THEN ((t1.duration_min - 45) * 0.20 + (t1.duration_min * 0.20))::NUMERIC::MONEY
				WHEN t1.bike_type LIKE 'electric bike'
					THEN (t1.duration_min * 0.20)::NUMERIC::MONEY
				WHEN t1.bike_type LIKE 'classic bike' AND t1.duration_min > 45
					THEN ((t1.duration_min - 45) * 0.20)::NUMERIC::MONEY
				ELSE 0::NUMERIC::MONEY
			END
		-- casual cost breakdown
		ELSE
			CASE
				WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min > 30
					THEN (3 + ((t1.duration_min - 30) * 0.30 + (t1.duration_min * 0.30)))::NUMERIC::MONEY
				WHEN t1.bike_type LIKE 'electric bike'
					THEN (3 + (t1.duration_min * 0.30))::NUMERIC::MONEY
				WHEN t1.bike_type LIKE 'classic bike' AND t1.duration_min > 45
					THEN (3 + (t1.duration_min - 30) * 0.30)::NUMERIC::MONEY
				ELSE 3::NUMERIC::MONEY
			END
	END AS trip_cost
FROM
	(SELECT
		ride_id,
		member_casual,

		CASE
			WHEN rideable_type LIKE 'electric_bike' THEN 'electric bike'
			ELSE 'classic bike'
		END AS bike_type,

	 	-- duration of the trip in min
		((DATE_PART('day', ended_at::TIMESTAMP - started_at::TIMESTAMP) * 24 + 
    		DATE_PART('hour', ended_at::TIMESTAMP - started_at::TIMESTAMP)) * 60 +
    		DATE_PART('minute', ended_at::TIMESTAMP - started_at::TIMESTAMP)) AS duration_min,

		start_lat,
		start_lng,
		end_lat,
		end_lng
	FROM baywheel_2020_2021
	) AS t1;


-- second query
-- aggregate sum of trip_cost into groups by year, month, member_casual
SELECT
	member_casual,
	year,
	month,
	SUM(t2.trip_cost) AS total
FROM
	(SELECT *,
		CASE
			-- member cost breakdown
			WHEN t1.member_casual LIKE 'member' THEN
				CASE
					WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min >= 55
						THEN (2 + (t1.duration_min * 0.20))::NUMERIC::MONEY
					WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min > 45 AND t1.duration_min < 55
						THEN ((t1.duration_min - 45) * 0.20 + (t1.duration_min * 0.20))::NUMERIC::MONEY
					WHEN t1.bike_type LIKE 'electric bike'
						THEN (t1.duration_min * 0.20)::NUMERIC::MONEY
					WHEN t1.bike_type LIKE 'classic bike' AND t1.duration_min > 45
						THEN ((t1.duration_min - 45) * 0.20)::NUMERIC::MONEY
					ELSE 0::NUMERIC::MONEY
				END
			-- casual cost breakdown
			ELSE
				CASE
					WHEN t1.bike_type LIKE 'electric bike' AND t1.duration_min > 30
						THEN (3 + ((t1.duration_min - 30) * 0.30 + (t1.duration_min * 0.30)))::NUMERIC::MONEY
					WHEN t1.bike_type LIKE 'electric bike'
						THEN (3 + (t1.duration_min * 0.30))::NUMERIC::MONEY
					WHEN t1.bike_type LIKE 'classic bike' AND t1.duration_min > 45
						THEN (3 + (t1.duration_min - 30) * 0.30)::NUMERIC::MONEY
					ELSE 3::NUMERIC::MONEY
				END
		END AS trip_cost
	FROM
		(SELECT
			ride_id,
			member_casual,
			CASE
				WHEN rideable_type LIKE 'electric_bike' THEN 'electric bike'
				ELSE 'classic bike'
			END AS bike_type,
	 		-- duration of the trip in min
			((DATE_PART('day', ended_at::TIMESTAMP - started_at::TIMESTAMP) * 24 + 
    			DATE_PART('hour', ended_at::TIMESTAMP - started_at::TIMESTAMP)) * 60 +
    			DATE_PART('minute', ended_at::TIMESTAMP - started_at::TIMESTAMP)) AS duration_min,
			start_lat,
			start_lng,
			end_lat,
			end_lng,
	 		DATE_PART('year', ended_at::TIMESTAMP) AS year,
			DATE_PART('month', ended_at::TIMESTAMP) AS month
		FROM baywheel_2020_2021
		) AS t1) AS t2
GROUP BY 
	month, 
	year, 
	member_casual
ORDER BY 
	year, 
	month;
