USE noaacdo;


/* 1. Write a query to list how many stations are found in each location. Output should list the 
location name and the station count, and the columns should have the headers 'Location' and 
'# Stations'. Only report locations with 100 or more stations, and list locations with the most stations first. */

SELECT location.name AS Location, count(*) AS `# Station` 
FROM stationbylocation
JOIN location 
ON location.locationid = stationbylocation.locid
GROUP BY locid
HAVING `# Station` > 100
ORDER BY `# Station` DESC;



/* 2. Write a query to list location name, the minimum elevation of its stations, the maximum 
elevation of its stations, and the average elevation of its stations. Include only those 
locations with 100 or more stations, and round the average elevation to just 1 decimal place. 
Locations with the highest average elevation should be listed first. */

SELECT location.name AS `Location name`, min(elevation), max(elevation), ROUND(avg(elevation), 1) 
FROM station
JOIN stationbylocation
ON stationbylocation.staid = station.stationid
JOIN location
ON location.locationid = stationbylocation.locid
GROUP BY locationid
HAVING count(staid) >= 100
ORDER BY avg(elevation) DESC;



/* 3. Write a query to list the location category name, the location name, the station name, and 
elevation of the locations that include the one station in the entire database that has the 
highest elevation. Your column headers should be “Category”, “Location”, “Station”, and 
“Elevation”. HINT: the station and elevation will be the same for all five rows of your output. */

SELECT locationcategory.name AS Category, location.name AS Location, station.name AS Station, max(station.elevation) AS Elevation 
FROM locationcategory
JOIN locationbycategory
ON locationbycategory.catid = locationcategory.lcid
JOIN location
ON location.locationid = locationbycategory.locid
JOIN stationbylocation
ON stationbylocation.locid = location.locationid
JOIN station 
ON station.stationid = stationbylocation.staid
GROUP BY Station;



/* 4A. Write a query to report station elevation, absolute value of the latitude, and average of the 
mean daily temperature measured at the station. Restrict your query to the year 2008 and later. Order by
elevation, and limit the query to just 50 results. NOTE: The “mean daily, temperature” at a station should
be calculated as (tmin + tmax)/2. Do not use TObs, as it is reported only by a small subset of the stations. */

SELECT elevation, abs(latitude), avg((tmin + tmax)/2) AS `Mean Daily Temperature` 
FROM station
JOIN tminmax
ON tminmax.stationid = station.stationid
WHERE year >= 2008 
GROUP BY tminmax.stationid
ORDER BY elevation DESC
LIMIT 50;


/* 4B. Write a query to report the average of each of the fields in the previous query. Write this 
query in 4 different ways; */

	# 1) Average over the 50 highest elevations 
	SELECT avg(highelevation.elevation) AS `Avg Highest Elevation` , abs(latitude), avg((tmin + tmax)/2) AS `Avg Temperature`
	FROM station 
	JOIN
	  (SELECT elevation, stationid
	  FROM station
	  ORDER BY elevation DESC
	  LIMIT 50) AS highelevation
	ON station.stationid = highelevation.stationid
    JOIN tminmax
    ON tminmax.stationid = station.stationid
    WHERE year >= 2008;
 
 
	# 2) Average over the 50 lowest elevations
	SELECT avg(lowelevation.elevation) AS `Avg Lowest Elevation`, abs(latitude), avg((tmin + tmax)/2) AS `Avg Temperature`
	FROM station 
	JOIN
	  (SELECT elevation, stationid
	  FROM station
	  ORDER BY elevation ASC
	  LIMIT 50) AS lowelevation
	ON station.stationid = lowelevation.stationid
	JOIN tminmax
    ON tminmax.stationid = station.stationid
    WHERE year >= 2008;


	# 3) Average over the 50 lowest latitudes (remember - latitude ranges from -90 to 90, so use the absolute value)
	SELECT avg(elevation) as 'Avg Elevation', avg(abs(latitude)) as 'Avg Lowest Latitude',avg((tmin+tmax)/2)  as 'Avg Mean Daily Temperature' 
	FROM station
	JOIN tminmax
	ON station.stationid = tminmax.stationid
	WHERE abs(latitude) in(
						 SELECT * 
						 FROM (SELECT distinct(abs(latitude)) 
						 FROM station 
						 WHERE stationid in 
										(SELECT stationid 
										 FROM tminmax 
										 WHERE year >= 2008)

						ORDER BY abs(latitude) ASC
						limit 50 ) AS t);


	# 4) Average over the 50 highest latitudes (again, use absolute values of latitudes) 
	SELECT avg(elevation) as 'Avg Elevation', avg(abs(latitude)) as 'Avg Highest Latitude',avg((tmin+tmax)/2)  as 'Avg Mean Daily Temperature' 
	FROM station
	JOIN tminmax
	ON station.stationid = tminmax.stationid
	WHERE abs(latitude) in(
						 SELECT * 
						 FROM (SELECT distinct(abs(latitude)) 
						 FROM station 
						 WHERE stationid in 
										(SELECT stationid 
										 FROM tminmax 
										 WHERE year >= 2008)

						ORDER BY abs(latitude) DESC
						limit 50 ) AS t);

/*  Station Category	Average Elevation	 Average Latitude	  Average Temperature
	High Elevation	    4447.004792272211	 38.36921		      3.6519594310039527   
	Low Elevation	   -31.243521693938035 	 36.4622			  19.869630833960596   
	Low Latitutes	 	306.9842175765445    3.4655892951826677   25.758772512057277   
	High Latitudes		60.89041707319168	 71.75999583760122   -6.6960706639693885  */  



/* 4C. Do the results suggest that the hypothesis has merit? Suggest how you might be able to 
quantify the variation in temperature with latitude. 

	   As we go higher elevation we expect lower pressure, therefore lower temperature. 
       According to the table shown above, the temperature difference makes sense.
       
       There is also similar relationship between latitudes and temperature. 
       While around the ecvator (latiude = 0) temperature is higher than the temperature in poles ( abs(latitude) = 90)
       According to the table shown above, the higher latitude has lower temperature.
       


/* 5A. Write a query to return the number of stations for which the station's maxdate's year is less than
 the maximum year in tminmax for that station. Use only those entries in tminmax where year >= 2000. */

SELECT count(*) AS `# Stations`
FROM (
	SELECT max(year) AS maxyear, stationid
    FROM tminmax
    WHERE year >= 2000
    GROUP BY stationid
) AS tmaxyear
JOIN station ON station.stationid = tmaxyear.stationid
WHERE year(station.maxdate) < tmaxyear.maxyear;


/* 5B. Write a query to return the count of locations for which the location's maxdate's year is less than
 the maximum year for any station in that location.  Again, use only those entries in tminmax where year >= 2000. */
 

SELECT count(*) AS `# Locations`
FROM location
JOIN stationbylocation
ON stationbylocation.locid = location.locationid
JOIN (
	SELECT max(year) AS maxyear, stationid
    FROM tminmax
    WHERE year >= 2000
    GROUP BY stationid
) AS tmaxyear
ON stationbylocation.staid = tmaxyear.stationid
WHERE year(location.maxdate) < tmaxyear.maxyear;


/* T(t) = Tmean + A*sin(2*π*(t-φ))
where t is time measured in days, Tmean is the yearly mean temperature, A is the amplitude of the seasonal fluctution, 
and φ is a phase offset representing seasonal “lag” - i.e., the difference between the date of the winter solstice 
and the day at which lowest temperature is typically observed. 

For the station data shown above (stationid=1115), write the following queries: */

# A. Write a query to estimate both Tmeanand A.
SELECT stationid, avg((tmax + tmin)/2) AS Tmean, (max(tmax) - min(tmin)) AS A
FROM tminmax
WHERE stationid = 1115
GROUP BY year;


# B. Estimating φ requires two steps:
# 1. Write a query to report the mean daily temperature averaged over the years 2008 to present.

SELECT stationid, avg(tmax + tmin)/2
FROM tminmax
WHERE year >= 2008 AND stationid = 1115;


# 2. Using the above in a sub query, select the day at which the minimum average temperature is observed.

SELECT t.dayofyear, t.tmin
FROM (
	SELECT stationid, avg(tmax + tmin)/2,  year
	FROM tminmax
	WHERE year >= 2008 AND stationid = 1115) AS t







