/*Driver Performance & Efficiency
1. Identify drivers who have received an average rating below 3.0 in the past three
months. What strategies can be implemented to improve their performance?
2. Find the top 5 drivers who have completed the longest trips in terms of distance.
What does this say about their working patterns?
3. Identify drivers with a high percentage of canceled trips. Could this indicate driver
unreliability?
*/

-- 1. Identify drivers who have received an average rating below 3.0 in the past three months. What strategies can be implemented to improve their performance?
select * from bookings
order by bookingdate desc;
select * from feedback;
select * from drivers;

drop view ps2 ;
create view ps2 as (
select 
d.driverid,
d.name,
b.BookingID,
f.CustomerRating,
f.DriverRating,
cancellationreason,
count(*) over(partition by d.name) as no_of_rides_past_3M,
avg(customerrating) over (partition by d.name) AS AVG_CUST_RATING,
avg(driverrating) over (partition by d.name) as ang_driver_rating
from bookings as b
join drivers as d
on b.driverid = d.driverid
 left join feedback as f
on b.BookingID =f.BookingID
where Bookingdate > '2025-07-10' -- taking todays date as 2025-10-10
and b.status in ('completed','cancelled'));

select 
driverid,
name,
no_of_rides_past_3M,
round(AVG_CUST_RATING,2) as AVG_CUST_RATING,
round(ang_driver_rating,2) as avg_driver_rating
from ps2
where AVG_CUST_RATING < 3
group by name
order by AVG_CUST_RATING ;

/*
 there are 19 drivers who have avg coustomer rating less than 3.0
 mostlty due to late comming or no driver available
 cancelletion giving than bad rating
 
 Critical Risk Identified:{19} drivers (approximately 37% of the active fleet) have an average Penalized Customer Rating below {3.0}
 in the last three months. This poses a severe risk to customer retention and platform reliability.

Immediate Suspension/Warning
All 19 drivers must be placed on a Performance Improvement Plan (PIP). 
Failure to achieve a penalized rating of {3.0} or higher within 30 days must result in temporary suspension or termination.

*/

-- 2. Find the top 5 drivers who have completed the longest trips in terms of distance.
-- What does this say about their working patterns?

drop view ps2b ;
create view ps2b as 
(select 
b.DriverID,
d.name,
b.BookingDate,
b.PickupLocation,
b.DropoffLocation,
b.DistanceKM,
b.Fare,
rank() over(partition by b.driverid order by b.distancekm desc)  as rndk,
b.Status
from bookings as b
join drivers as d
using (driverid)
where status = "completed"
order by distancekm desc );

select * from ps2b
where rndk = 1 
limit 5 ;

/*
Maximum Range Capability: Drivers included in this group have all completed at least one trip of approximately 25 KM} (the maximum distance recorded). 
This establishes their willingness and capacity to cover the entire service radius, making them crucial for maintaining long-distance coverage.
*/

-- 3. Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability?

select * from customers;
select * from bookings;

with cte_1 as (
Select 
d.name,
count(b.status) as no_of_rides,
b.status
from drivers as d
join bookings as b 
using(driverid)
group by d.name,
		b.status) 
,cte_cancelled as (
select * from cte_1
where status = "cancelled"
)
,cte_completed as (
select * from cte_1 
where status ="completed"
)
select
ca.name,
ca.no_of_rides as cancelled_rides,
co.no_of_rides as completed_rides,
(co.no_of_rides+ca.no_of_rides) as total_rides,
round((ca.no_of_rides/(co.no_of_rides+ca.no_of_rides))*100,2) as percent_ride_cancelled
from cte_cancelled as ca
join cte_completed as co
using(name)
where round((ca.no_of_rides/(co.no_of_rides+ca.no_of_rides))*100,2) >= 25
order by percent_ride_cancelled desc ;

/* 
Setting the threshold at 25% reveals a high-risk group of 18 drivers who exhibit critically poor operational reliability. 
This signals a systemic issue where drivers are frequently failing to complete assigned trips, creating friction and frustration for customers.

1. Key Finding: The Unreliability Cluster The analysis confirms 17 drivers (out of 50 total active drivers) have a cancellation rate of 25% or higher.
Most Critical Tier 30%: Three drivers—Jennifer Smith (33.93%),
									   Shelia Love (30.77%),
									   Brianna Mullins ({29.63%)
—are in immediate need of severe corrective action, 
as they fail to complete nearly one-third of their assigned work.

High-Risk Tier (25% to 30%): This tier of 14 drivers requires mandatory intervention to prevent them from slipping into the Critical Tier.

2. Strategic Mandate: Zero Tolerance for Unreliability
                      The severity and scale of this problem demand a decisive, fleet-wide policy change to enforce reliability.
                      1) Priority Metric: The Driver Cancellation Rate must be immediately adopted as a primary Key Performance Indicator (KPI) for fleet management.
                      2)Immediate Action (Threshold 25%): All 18 drivers must be placed on a formal Performance Improvement Plan (PIP) focusing exclusively on trip completion.
                      3)Long-Term Goal: The acceptable fleet-wide cancellation rate must be set below (15%), 
                                       requiring strict penalties (including suspension or termination) for drivers who cannot meet the minimum reliability standards.
                                       
                                       
*/
