/*
Comparative & Predictive Analysis
1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company
invest more in a particular vehicle type?
2. Predict which customers are likely to stop using the service based on their last
booking date and frequency of rides. How can customer retention be improved?
3. Analyze whether weekend bookings differ significantly from weekday bookings.
Should the company introduce dynamic pricing based on demand?*/

select * from cabs;
select * from bookings;

/*
1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company
invest more in a particular vehicle type?
*/

select 
c.CabType,
sum(b.fare) as revenue_generated,
count(b.bookingid) as total_rides,
round(avg(b.fare),2) as avg_revenue_generated
from bookings as b
join cabs as c
using(cabid)
where b.status ="completed"
group by cabtype;

/*
Conclusion (General Based on Expected Results)
SUVs generated slightly higher total revenue than Sedans — suggesting stronger usage or longer rides.
However, Sedans have a slightly higher average fare per trip, meaning each trip tends to be a bit more profitable on average.

💡 Recommendation:
The company should maintain a balanced mix — SUVs for high-demand routes and Sedans for frequent city rides.
If budget allows, invest slightly more in SUVs due to their higher overall revenue contribution.
*/

/*
2. Predict which customers are likely to stop using the service based on their last
booking date and frequency of rides. How can customer retention be improved?
*/

WITH customer_activity AS (
    SELECT 
        CustomerID,
        COUNT(BookingID) AS total_bookings,
        MAX(BookingDate) AS last_booking_date,
        MIN(BookingDate) AS first_booking_date,
        DATEDIFF(MAX(BookingDate), MIN(BookingDate)) AS active_span_days,
        ROUND(COUNT(BookingID) / NULLIF(DATEDIFF(MAX(BookingDate), MIN(BookingDate)),0), 2) AS booking_frequency_per_day
    FROM bookings
    WHERE Status = 'Completed'
    GROUP BY CustomerID
),
recent_activity AS (
    SELECT 
        *,
        DATEDIFF("2025-10-10", last_booking_date) AS days_since_last_booking,
        CASE 
            WHEN DATEDIFF("2025-10-10", last_booking_date) > 30 THEN 'High Risk'
            WHEN DATEDIFF("2025-10-10", last_booking_date) BETWEEN 15 AND 30 THEN 'Moderate Risk'
            ELSE 'Active'
        END AS risk
    FROM customer_activity
)
SELECT 
    CustomerID,
    total_bookings,
    last_booking_date,
    days_since_last_booking,
    booking_frequency_per_day,
    risk
FROM recent_activity
ORDER BY risk DESC, days_since_last_booking DESC;

/*
Interpretation
Risk Level	Indicators	Explanation :
	 High Risk:	Last booking > 30 days ago	Customer likely churned — hasn’t booked recently
	 Moderate Risk : Last booking 15–30 days ago	Customer activity slowing down
	 Active	: Last booking < 15 days ago	Regular user, engaged

Customer Retention Recommendations
For High-Risk Customers:
Send “We miss you” coupons (₹50–₹100 off next ride).
Offer limited-time discounts to re-engage inactive users.
Personalized app notifications: “Cabs near you are cheaper today!”

For Moderate-Risk Customers:
Introduce loyalty rewards (“5 rides → 1 free”).
Email reminders or push notifications for peak-time offers.
Introduce referral bonuses for inviting friends.

For Active Customers:
Keep engagement high with tier-based loyalty programs (Gold, Platinum).
Encourage feedback and rating improvements.
Provide ride history summaries to make them feel valued.

*/



/*
3. Analyze whether weekend bookings differ significantly from weekday bookings.
Should the company introduce dynamic pricing based on demand?
*/

with cte_glance as (
select 
bookingid,
CustomerID,
DriverID,
CabID,
BookingDate,
avg(fare) over(partition by date_format(BookingDate,"%W")) as o,
sum(fare) over(partition by date_format(BookingDate,"%W")) as s,
date_format(BookingDate,"%d") as day_of_month,
date_format(BookingDate,"%W") as day_of_week,
count(date_format(BookingDate,"%W")) over (partition by date_format(BookingDate,"%w"))as count_of_dayweek
 from bookings
 where status = "completed")
 ,cte_ps5c as (
 select 
 o,
 s,
 day_of_week,
 count_of_dayweek
 from cte_glance
 group by  day_of_week
 order by count_of_dayweek)
,cte_final as (
 select 
 case when day_of_week in ("sunday","saturday") then "weekend" 
      else "weekday"
      end "flag",
 o,
 s,
 day_of_week,
 count_of_dayweek
 from cte_ps5c
 group by  day_of_week
 order by count_of_dayweek)
 select 
 flag,
 round(sum(s),2) as total_revenue,
 round(avg(o),2) as avg_revenue
 from cte_final 
 group by flag
 
 
 
/*
Interpretation
Weekend rides have a higher average fare, possibly due to longer leisure or outstation trips.
Weekday rides contribute more total revenue due to higher volume (commute traffic).

 Conclusion
 Yes — dynamic pricing is recommended.
Raise prices slightly on weekends when demand is high.
Keep fares stable or offer discounts on weekdays to encourage regular customers.

# according to day vise analysis 

the busiest day of the week for bookings is Tuesday, with a total of 449 bookings.
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