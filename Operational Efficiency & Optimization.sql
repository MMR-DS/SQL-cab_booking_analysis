/*
Operational Efficiency & Optimization
1. Analyze the average waiting time (difference between booking time and tripstart
time) for different pickup locations. How can this be optimized to reduce delays?
2. Identify the most common reasons for trip cancellations from customer feedback.
What actions can be taken to reduce cancellations?
3. Find out whether shorter trips (low-distance) contribute significantly to revenue.
Should the company encourage more short-distance rides?
*/


/*
1. Analyze the average waiting time (difference between booking time and tripstart
time) for different pickup locations. How can this be optimized to reduce delays?
*/

create view ps4a as (
select 
b.driverid,
d.name,
-- minute(timediff(TripStart,BookingDate))as minute_per_ride,
round(avg(minute(timediff(b.TripStart,b.BookingDate))),2) as avg_wait_per_ride,
count(*) as total_rides
from bookings as b
join drivers as d
using(driverid)
group by b.driverid );

select *,
round(avg(avg_wait_per_ride) over(),2) as total_avg from ps4a 
order by avg_wait_per_ride desc ;

/*
 Average Waiting Time by Pickup Location:- The average waiting time for a cab,
										   from the moment a customer books until the trip officially starts,
                                           is consistently around 17 to 18 minutes across all locations.

The company should use this driver-specific data to enforce performance standards and improve dispatch efficiency.
Set Performance Thresholds: Establish a maximum acceptable average waiting time (e.g., 10 minutes). 
							Any driver consistently exceeding this threshold requires immediate intervention.

Driver Retraining/Warning: Drivers with the highest average wait times should be flagged for performance review. 
						   Training should focus on optimizing their current location relative to high-demand areas (as identified in previous analyses) 
                           and improving their speed in accepting and mobilizing for bookings.

Dispatch Optimization: Use the low-wait-time drivers as a benchmark. 
					   The dispatch system should prioritize assigning bookings to drivers who are known to have a low wait time, 
                       even if a slightly closer but high-wait-time driver is available. This uses historical reliability to improve future customer experience.

Targeted Incentives: Offer small performance bonuses to drivers who maintain an average wait time below a specific,
					 challenging target (e.g., 8 minutes), encouraging quick pick-ups.

*/

/*
2. Identify the most common reasons for trip cancellations from customer feedback.
What actions can be taken to reduce cancellations?
*/

select
CancellationReason,
reason_count,
(select count(*) from ps1b) as total_reason, -- thought of using last value but not happening (can i?) so used (select subquery since it gives scalar answer)
round((reason_count/(select count(*) from ps1b))*100,2) as percent_reason
from ps1b
group by CancellationReason
order by percent_reason desc;

/*
Insights: Reasons for Frequent Cancellations
The aggregated data on cancellation reasons provides clear insights into the potential problems faced by these high-risk customers:

1. Service Supply Issue (23.43%)
Reason: "No driver" 
Behavioral Insight: These customers are frequently booking in areas or at times where driver availability is low. 
					They are likely waiting for a confirmed ride but are forced to cancel (or the system auto-cancels) because no driver accepts the request.

Actionable Strategy: The company must focus on improving driver density or incentivizing drivers to service the specific pickup locations and times used by these customers.

2. Operational/Wait-Time Issue (20.57%)
Reason: "Late booking" (which often means the driver was late, or the customer found a faster alternative while waiting).
Behavioral Insight: The customer needs are time-sensitive.
					The wait time after booking may be too long, causing frustration and leading the customer to cancel and seek another mode of transport.

Actionable Strategy: Reduce estimated wait times in key zones.
					 Providing more accurate, lower estimated times for high-cancelling customers could reduce friction.

3. Customer-Driven Issues (30.0% & 26.0%)
Reason: "Change of plans" and "Payment issue."

Behavioral Insight: These cancellations are generally outside the company's direct operational control,
					but are still worth investigating.
                    "Change of plans" indicates lack of firmness in travel intention or potentially a last-minute better deal elsewhere. 
                    "Payment issue" suggests technical glitches or card rejections.

Actionable Strategy: For "Change of plans," consider a small cancellation fee to encourage commitment, or pre-booking/scheduled ride options for greater certainty.
					 For "Payment issue," ensure the payment process is robust and quick.

In summary, the primary reason frequent cancellation customers are leaving is a failure of the service to provide a driver in a timely manner, suggesting a fundamental supply-demand imbalance.
*/

/*
3. Find out whether shorter trips (low-distance) contribute significantly to revenue.
Should the company encourage more short-distance rides?
*/

with cte_ps4c as (
		select 
		DistanceKM,
		Fare,
		case when DistanceKM > 12.5 then "long_distance"
			 else "short_distance"
			 end "flag"
		from bookings
		where status = "completed")
,cte_4_3_1 as (select
flag,
sum(fare) as revenue_on_distance,
(select sum(fare) from bookings where status ="completed")  as total_revenue,
count(*) total_rides,
(select count(fare) from bookings where status ="completed") as total_count
from cte_ps4c
group by flag)
select 
flag,
revenue_on_distance,
total_revenue,
round(((revenue_on_distance/total_revenue)*100),2) as revenue_percent,
total_rides,
total_count,
round((total_rides/total_count)*100,2) as ride_contribution
from cte_4_3_1;


/*
After analyzing the total revenue and ride count for both short- and long-distance trips:
1)Short-distance trips have a higher ride volume and often contribute a significant portion of total revenue, even though each trip earns less individually.
2)Long-distance trips generate higher fare per ride, but occur less frequently, leading to lower overall revenue contribution.

Insight:
Shorter trips drive consistent demand and faster turnover, keeping drivers active and ensuring better utilization of vehicles.

Business Recommendation:
The company should: Encourage short-distance rides by offering quick-ride discounts or loyalty points.
					Optimize cab placement in high-demand urban zones.
					Maintain balanced pricing to ensure profitability even for shorter trips.
*/ 

