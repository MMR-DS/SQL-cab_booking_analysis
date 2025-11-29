create database sql_project_trips;
use sql_project_trips;

/*Customer and Booking Analysis
1. Identify customers who have completed the most bookings. What insights can you
draw about their behavior?
2. Find customers who have canceled more than 30% of their total bookings. What
could be the reason for frequent cancellations?
3. Determine the busiest day of the week for bookings. How can the company optimize
cab availability on peak days?
*/
select * from bookings;
SELECT * from customers;

-- creating view of this query to use it as table to extract more details.

create view most_bookings as (
					select
					b.customerid,
					b.bookingid,
                    b.PickupLocation,
                    b.dropofflocation,
					count(b.customerid) over(partition by b.customerid ) as no_of_rides,
					t.PaymentMethod,
                    b.BookingDate,
                    b.TripStart,
					avg(b.DistanceKM) over(partition by customerid) avg_distance_per_customer,
					b.Fare,
					avg(b.fare) over(partition by b.customerid) avg_fare_per_customer,
					b.Status
					from bookings as b
					join tripdetails as t
					using (BookingID)
					where status in ('completed'));
				

-- drop view most_bookings ;	

select * from most_bookings
order by no_of_rides desc ;
-- ---------------------------------------------------------------------------------------------
select * from tripdetails;
-- ---------------------------------------------------------------------------------------------

	with cte_most_bookings as (
			select *
			from most_bookings)
			,
	cte_most_pickups as (
			select
			customerid,
			pickuplocation,
			count(pickuplocation) as mp,
			no_of_rides,
			row_number() over( partition by customerid order by count(pickuplocation) desc) rnp
			from most_bookings
			group by customerid,pickuplocation
			order by no_of_rides desc,
			count(pickuplocation) desc
			)
	,cte_most_dropoff as (
			select
			customerid,
			dropofflocation,
			count(dropofflocation) as mp,
			no_of_rides,
			row_number() over( partition by customerid order by count(dropofflocation) desc) rnd
			from most_bookings
			group by customerid,dropofflocation
			order by no_of_rides desc,
			count(dropofflocation) desc
			)
	, cte_payment_mode as (
			select
			customerid,
			PaymentMethod,
			count(PaymentMethod) as pm,
			no_of_rides,
			row_number() over( partition by customerid order by count(PaymentMethod) desc) rnpm
			from most_bookings
			group by customerid,PaymentMethod
			order by no_of_rides desc,
			count(PaymentMethod) desc
            )
	,cte_customer as (
			select 
			customerid,
			name
			from customers
			)
	,cte_ps_1a as (
	select 
	cmb.customerid,
	cc.name,
	cmp.pickuplocation as most_freq_pickup,
	cmd.dropofflocation as most_freq_dropoff,
	cmb.no_of_rides,
	concat(round(cmb.avg_distance_per_customer,2),' KM')as avg_distance_per_customer,
	CONCAT(round(cmb.avg_fare_per_customer,2),' RS' )as avg_fare_per_customer,
    cpm.PaymentMethod,
    cpm.pm as most_freq_pm_count
	from cte_most_bookings as cmb
	join cte_customer as cc
	using(customerid)
	left join cte_most_pickups as cmp
	on cmb.customerid = cmp.customerid
    left join cte_payment_mode as cpm
    on cpm.customerid =cmb.customerid
	left join cte_most_dropoff as cmd
	on cmb.customerid = cmd.customerid
	where cmp.rnp = 1 and
		  cmd.rnd = 1 and
          cpm .rnpm = 1
	group by cmb.customerid
	order by cmb.no_of_rides desc,
			cmb.avg_distance_per_customer desc
	limit 15)
    select *,
    round(avg(avg_distance_per_customer) over(),2) as avg_dist ,
    round(avg(avg_fare_per_customer) over(),2) as avg_fare
    from cte_ps_1a as ps1a
    order by ps1a.no_of_rides desc,
    PS1A.avg_distance_per_customer DESC;
    

        
   #  1. Identify customers who have completed the most bookings. What insights can you draw about their behavior? 
/*
THE FOLLOWING ARE TOP 15 FREQUENT CUSTOMERS
FROM THIS DATA WE CAN SAY THAT 

Behavioral Insights from the Top Customers
Overall Average Distance: ≈ 13.20 KM
Overall Average Fare: ≈ 164.57

1. Trip Frequency and Loyalty
The most obvious insight is their high frequency. 
These customers have completed 8 to 12 rides in the dataset,
 making them highly loyal and valuable users.

2. Trip Distance and Value
Long-Distance Commuters: Customers like Michael Hunter (151) (18.23 KM average)
                                        Anthony Garcia (464) (16.24 KM average) 
										Marcus May (77) (15.28 KM average)
have significantly longer average trip distances and higher fares than the overall average. 
They are high-value customers who likely use the service for less frequent but longer journeys.

Short-Distance Regulars: Sherry Anthony (488) (10.70 KM average) 
						Robert Summers (40) (10.17 KM average)
have shorter average trip distances. They might be using the service for daily, 
local commutes (e.g., getting to a station or a local office).

3. Commute Patterns (Pickup/Dropoff)
The most frequent locations reveal their common travel needs:

Market/Mall Focus: Hunter Pennington (28),
				   Marcus Price (104), 
				   Sherry Anthony (488),
				   Kent Collins (130) 
all frequently travel to the Mall. This suggests their usage is often related to shopping or leisure activities.

Business/Travel Focus: Brandon Brown (14)
					   Steven Webb (148)
					   Alejandro Warren (408)
					   Jordan Johnson (20)
					   Mr. Bradley Holden (83)
                       Customers frequently using the Airport, Office, or Station 
                       are likely business commuters or regular travelers or profesionals.

Consistent Routes: The fact that they have a distinct 
                   "Most Frequent Pickup" and "Most Frequent Dropoff" 
                   suggests predictable and repeatable travel patterns, such as a work commute (e.g., Hotel to Office for Anthony Garcia And Marcus May).

4. Payment Preference
The preferred payment methods are diverse, but Wallet (7) and Cash (6) are slightly more common than Card (3) among the top 15.
This indicates they are comfortable with digital payment methods, which can offer greater convenience and potentially faster service.

*/


create view most_bookings_comp as(
		select
		CustomerID,
		Status,
		count(status) as no_of_booking
		from bookings
		where status in ('completed')
		group by customerid
		order by count(status) desc
                 );
                 
create view most_bookings_cancel as(
		select
		CustomerID,
		Status,
		count(status) as no_of_booking_cancel
		from bookings
		where status in ('cancelled')
		group by customerid
		order by count(status) desc);
        
select * from most_bookings_comp;
select * from most_bookings_cancel;

drop view ps1b;
create view ps1b_process as (
		select 
        b.bookingid,
		mbcp.customerid,
		mbcp.no_of_booking as no_of_completed_booking,
		mbca.no_of_booking_cancel as no_of_cancelled_booking
		from most_bookings_comp as mbcp
		join most_bookings_cancel as mbca
		using(customerid)
        join bookings as b
        using (customerid));
 
 create view ps1b as (
select 
customerid,
Name,
bookingid,
no_of_completed_booking,
no_of_cancelled_booking,
CancellationReason,
round((no_of_cancelled_booking/(no_of_completed_booking+no_of_cancelled_booking))*100,2) as percent_cancelled,
count(CancellationReason) over (partition by CancellationReason) as reason_count
from ps1b_process
join customers
using(customerid)
join feedback
using (BookingID)
where round((no_of_cancelled_booking/(no_of_completed_booking+no_of_cancelled_booking))*100,2) > 30
     and CancellationReason not in (" ")
order by reason_count,
		 customerid,
		 percent_cancelled desc
		 );

select * from feedback;

      # Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?
# to see cancelation reason distribution in percentage
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

# to all customers who have cancelled ride more than 30% of times 
select * from ps1b;

select *,
count(status) from bookings 
group by status;

-- ---------------------------------------------------------------------------------------------
-- 3. Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?


with cte_glance as (
select 
bookingid,
CustomerID,
DriverID,
CabID,
BookingDate,
date_format(BookingDate,"%d") as day_of_month,
date_format(BookingDate,"%W") as day_of_week,
count(date_format(BookingDate,"%W")) over (partition by date_format(BookingDate,"%w"))as count_of_dayweek
 from bookings)
 select 
 day_of_week,
 count_of_dayweek
 from cte_glance
 group by  day_of_week
 order by count_of_dayweek;
 
/*
he busiest day of the week for bookings is Tuesday, with a total of 449 bookings.
Overall, the booking volume is quite consistent throughout the week, 
with Mondays (435), Thursdays (437), and Saturdays (447) also seeing high activity.
 Fridays (393) and Sundays (407) are slightly quieter.
 
  Driver Incentives and Scheduling 💰
Peak Day Bonuses: Offer surge or monetary bonuses specifically for drivers who complete a minimum number of trips during the peak hours on Tuesday and Saturday. 
                  This directly tackles driver supply issues.

Tiered Commission: Temporarily lower the company's commission during peak hours on these days, 
                   increasing the driver's take-home pay and making it more attractive to drive.


2. Predictive Dispatch and Supply Management 🗺️
Predictive Hotspots: Use data from Tuesday's peak hours to identify the most frequent pickup zones 
                     (e.g., Office areas or Market in the morning) and pre-position available cabs in these areas just before the demand spike.

Targeted Driver Communication: Send proactive, personalized messages to drivers on Monday night and Friday night, 
                               alerting them to the anticipated high demand on the upcoming peak day, encouraging them to sign on.

Cab Type Optimization: If certain cab types (e.g., Sedan or SUV) are more popular on peak days, incentivize those specific vehicle owners to drive.
*/


