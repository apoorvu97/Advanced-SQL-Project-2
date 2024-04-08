use mavenfuzzyfactory ;

-- Analyzing channel portfolios --

select 
	utm_source,
    utm_campaign
from website_Sessions
group by 1,2 ;

select
	min(date(website_sessions.created_at)) as week_start_date,
    count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_Sessions.website_session_id else null end) as gsearch_sessions,
    count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_Sessions.website_session_id else null end) as bsearch_sessions
from website_sessions
where website_sessions.created_At between '2012-08-22' and '2012-11-29'
group by week(website_sessions.created_at) ;

-- Comparing channel characteristics --

select
	device_type 
from website_sessions
group by 1 ;

select
	utm_source,
	count(website_session_id) as sessions,
    count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
    count(distinct case when device_type = 'mobile' then website_session_id else null end)/count(website_session_id) as pct_mobile
from website_sessions
where created_at between '2012-08-22' and '2012-11-30'
and utm_source in ('bsearch', 'gsearch')
and utm_campaign = 'nonbrand'
group by 1 
order by sessions asc ;

-- Cross-Channel bid optimization --

select 
	website_sessions.device_type as device_type,
    website_Sessions.utm_source as utm_source,
    count(distinct website_Sessions.website_Session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_Sessions.website_Session_id) as conv_rate
from website_Sessions left join orders on website_Sessions.website_Session_id = orders.website_session_id
where website_Sessions.created_at between '2012-08-22' and '2012-09-18'
and utm_Source in ('bsearch', 'gsearch')
and utm_campaign = 'nonbrand'
group by 1, 2 
order by conv_rate desc ;

-- Analyzing channel portfolio trends --

select
	min(date(created_At)) as week_start_date,
    count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_dtop_session,
	count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_dtop_session,
	concat((count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end))*100, ' %') as b_pct_of_g_dtop,
    count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_mob_session,
    count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_mob_session,
    concat((count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)/count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end))*100, ' %') as b_pct_of_g_mob
from website_sessions
where created_At between '2012-11-04' and '2012-12-22'
and utm_campaign = 'nonbrand'
group by week(created_At) ;

-- Analyzing Direct, Brand-driven traffic --

select
	utm_source,
    utm_campaign,
    http_referer
from website_Sessions
group by 1,2,3 ;

select
	year(created_At) as 'Year',
    month(created_At) as 'Month',
    count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand,
    count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'brand' then website_session_id else null end) as brand,
    concat((count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'brand' then website_session_id else null end)/count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then website_session_id else null end))*100, ' %') as brand_pct_of_nonbrand,
    count(distinct case when http_referer is null then website_session_id else null end) as direct,
    concat((count(distinct case when http_referer is null then website_session_id else null end)/count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then website_session_id else null end))*100, ' %') as direct_pct_of_nonbrand,
    count(case when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then website_Session_id else null end) as organic,
    concat((count(case when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then website_Session_id else null end)/count(distinct case when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then website_session_id else null end))*100, ' %') as organic_pct_of_nonbrand
from website_Sessions
where created_at < '2012-12-23'
group by 1, 2 ;

-- Analyzing business seasonality --

select
	year(website_sessions.created_at) as year,
    month(website_sessions.created_at) as month,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by 1, 2 ;

select
	min(date(website_sessions.created_At)) as week_start_date,
	count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-01-01'
group by week(website_sessions.created_At) ; 

-- Analyzing business patterns --
 
 select
	hr,
    round(avg(case when wkday = 0 then website_sessions else null end), 1) as mon,
    round(avg(case when wkday = 1 then website_sessions else null end), 1) as tue,
    round(avg(case when wkday = 2 then website_sessions else null end), 1) as wed,
    round(avg(case when wkday = 3 then website_sessions else null end), 1) as thu,
    round(avg(case when wkday = 4 then website_sessions else null end), 1) as fri,
    round(avg(case when wkday = 5 then website_sessions else null end), 1) as sat,
    round(avg(case when wkday = 6 then website_sessions else null end), 1) as sun
 from
(
select 
date(created_at) as created_date,
weekday(created_At) as wkday,
hour(created_At) as hr,
count(distinct website_Session_id ) as website_sessions
from website_sessions
where created_At between '2012-09-15' and '2012-11-15'
group by 1, 2, 3 
) as daily_hourly_session
group by 1 ;

-- Product-level sales analysis --

select 
	year(created_At) as yr,
    month(created_At) as mon,
    count(order_id) as number_of_sales,
    concat(sum(price_usd), ' $') as total_revenue,
    concat(sum(price_usd - cogs_usd), ' $') as total_margin
from orders
where created_at < '2013-01-04'
group by 1,2 ;

-- Analyzing product launches --

select 
	primary_product_id 
from orders 
where created_At between '2012-04-01' and '2013-04-04' 
group by 1 ;

select 
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as mon,
    count(orders.order_id) as orders,
    count(orders.order_id)/count(website_sessions.website_Session_id) as conv_rate,
    concat(round(sum(orders.price_usd)/count(website_sessions.website_Session_id), 2), ' $') as revenue_per_session,
    count(case when orders.primary_product_id = 1 then orders.order_id else null end) as product_one_orders,
    count(case when orders.primary_product_id = 2 then orders.order_id else null end) as product_two_orders
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_At between '2012-04-01' and '2013-04-04'
group by 1, 2 
order by 1, 2 ;

-- Product-level website pathing --

select 
	primary_product_id
from orders
where created_at < '2013-01-06' 
group by 1 ;

select
	pageview_url
from website_pageviews 
where created_at < '2013-04-05'
group by 1 ;
	
		-- 	Pre_product_2 --    

create temporary table a
select
	concat('A.', ' Pre_Product_2') as Time_period,
    count(website_session_id) as sessions,
    count(case when products_page = 1 then website_session_id else null end) as product_page_visited,
    concat((count(case when products_page = 1 then website_session_id else null end)/count(website_session_id))*100, ' %') as clr_product_page,
    count(case when mr_fuzzy_page = 1 then website_session_id else null end) as mr_fuzzy_or_love_bear_page_visited,
	concat((count(case when mr_fuzzy_page = 1 then website_session_id else null end)/count(case when products_page = 1 then website_session_id else null end))*100, ' %') as clr_mr_fuzzy_or_love_bear_page,
    count(case when cart_page = 1 then website_session_id else null end) as cart_page_visited,
    concat((count(case when cart_page = 1 then website_session_id else null end)/count(case when mr_fuzzy_page = 1 then website_session_id else null end))*100, ' %') as clr_cart_page,
    count(case when shipping_page = 1 then website_session_id else null end) as shipping_page_visited,
    concat((count(case when shipping_page = 1 then website_session_id else null end)/count(case when cart_page = 1 then website_session_id else null end))*100, ' %') as clr_shipping_page,
    count(case when billing_page = 1 then website_session_id else null end) as billing_page_visited,
	concat((count(case when billing_page = 1 then website_session_id else null end)/count(case when shipping_page = 1 then website_session_id else null end))*100, ' %') as clr_billing_page,
    count(case when thank_you_page = 1 then website_session_id else null end) as thank_you_page_visited,
    concat((count(case when thank_you_page = 1 then website_session_id else null end)/count(case when billing_page = 1 then website_session_id else null end))*100, ' %') as clr_thank_you_page
from
(
select
	website_sessions.created_at,
    website_sessions.website_Session_id,
    website_pageviews.pageview_url,
    case when pageview_url = '/products' then 1 else null end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else null end as mr_fuzzy_page,
    case when pageview_url = '/cart' then 1 else null end as cart_page,
    case when pageview_url = '/shipping' then 1 else null end as shipping_page,
    case when pageview_url = '/billing' or pageview_url = '/billing-2' then 1 else null end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else null end as thank_you_page
from website_sessions left join website_pageviews on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between '2012-10-05' and '2013-01-05' 
) as table_a ;

create temporary table b
select
	concat('A.', ' Post_Product_Product_2') as Time_period,
    count(website_session_id) as sessions,
    count(case when products_page = 1 then website_session_id else null end) as product_page_visited,
    concat((count(case when products_page = 1 then website_session_id else null end)/count(website_session_id))*100, ' %') as clr_product_page,
    count(case when mr_fuzzy_page = 1 then website_session_id else null end) as mr_fuzzy_or_love_bear_page_visited,
	concat((count(case when mr_fuzzy_page = 1 then website_session_id else null end)/count(case when products_page = 1 then website_session_id else null end))*100, ' %') as clr_mr_fuzzy_or_love_bear_page,
    count(case when cart_page = 1 then website_session_id else null end) as cart_page_visited,
    concat((count(case when cart_page = 1 then website_session_id else null end)/count(case when mr_fuzzy_page = 1 then website_session_id else null end))*100, ' %') as clr_cart_page,
    count(case when shipping_page = 1 then website_session_id else null end) as shipping_page_visited,
    concat((count(case when shipping_page = 1 then website_session_id else null end)/count(case when cart_page = 1 then website_session_id else null end))*100, ' %') as clr_shipping_page,
    count(case when billing_page = 1 then website_session_id else null end) as billing_page_visited,
	concat((count(case when billing_page = 1 then website_session_id else null end)/count(case when shipping_page = 1 then website_session_id else null end))*100, ' %') as clr_billing_page,
    count(case when thank_you_page = 1 then website_session_id else null end) as thank_you_page_visited,
    concat((count(case when thank_you_page = 1 then website_session_id else null end)/count(case when billing_page = 1 then website_session_id else null end))*100, ' %') as clr_thank_you_page
from
(
select
	website_sessions.created_at,
    website_sessions.website_Session_id,
    website_pageviews.pageview_url,
    case when pageview_url = '/products' then 1 else null end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' or pageview_url = '/the-forever-love-bear' then 1 else null end as mr_fuzzy_page,
    case when pageview_url = '/cart' then 1 else null end as cart_page,
    case when pageview_url = '/shipping' then 1 else null end as shipping_page,
    case when pageview_url = '/billing' or pageview_url = '/billing-2' then 1 else null end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else null end as thank_you_page
from website_sessions left join website_pageviews on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at between '2013-01-06' and '2013-04-05' 
) as table_b ;

select * from a
union
select * from b ;

-- Building product-level conversion funnels --

select 
    website_pageviews.pageview_url as url,
	count(*)
from website_pageviews
where created_at between '2013-01-06' and '2013-04-10' 
group by 1 ;

create temporary table c
select 
	website_session_id,
    pageview_url
from website_pageviews
where pageview_url = '/the-original-mr-fuzzy' 
and created_at between '2013-01-06' and '2013-04-10' ;

select * from c ;

create temporary table d
select
	c.website_session_id,
    website_pageviews.pageview_url,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as product_vis,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_vis,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_vis,
    case when website_pageviews.pageview_url = '/billing-2' then 1 else 0 end as billing_vis,
    case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_vis
from c left join website_pageviews on c.website_session_id = website_pageviews.website_Session_id ;

select * from d ;

create temporary table e
select
	concat('mrfuzzy') as Product_seen,
    sum(d.product_vis) as sessions,
    sum(d.cart_vis) as to_cart,
    sum(d.shipping_vis) as to_shipping,
    sum(d.billing_vis) as to_billing,
    sum(d.thank_you_vis) as to_thankyou
from d ;

select * from e ;

create temporary table f
select 
	website_session_id,
    pageview_url
from website_pageviews
where pageview_url = '/the-forever-love-bear' 
and created_at between '2013-01-06' and '2013-04-10' ;

select * from f ;

create temporary table g
select
	f.website_session_id,
    website_pageviews.pageview_url,
    case when website_pageviews.pageview_url = '/the-forever-love-bear' then 1 else 0 end as product_vis,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as cart_vis,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as shipping_vis,
    case when website_pageviews.pageview_url = '/billing-2' then 1 else 0 end as billing_vis,
    case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you_vis
from f left join website_pageviews on f.website_session_id = website_pageviews.website_Session_id ;

select * from g ;

create temporary table h
select
	concat('lovebear') as Product_seen,
    sum(g.product_vis) as sessions,
    sum(g.cart_vis) as to_cart,
    sum(g.shipping_vis) as to_shipping,
    sum(g.billing_vis) as to_billing,
    sum(g.thank_you_vis) as to_thankyou    
from g ;

	-- Result_1 --

create temporary table i
select * from e 
union 
select * from h ; 

select * from i 
order by sessions asc ;

	-- Result_2 --

select
	Product_seen,
    to_cart/sessions as cart_clr,
    to_shipping/to_cart as shipping_clr,
    to_billing/to_shipping as billing_clr,
    to_thankyou/to_billing as thankyou_clr
from i 
order by cart_clr desc ;

-- Cross-Sell analysis --

	-- When items_purchased > 1, then cross-selling happened --

select * from orders ;

	-- If is_primary_item = 0 then it is a cross-sell --

select * from order_items ;

	-- Joining order and order_items table --
        
select 
    orders.primary_product_id,
    order_items.product_id as cross_sell_product,
    count(distinct orders.order_id) as orders
from orders left join order_items on order_items.order_id = orders.order_id
and order_items.is_primary_item = 0 -- cross-sell only
group by 1, 2 ;

	-- Assignment --

create temporary table sessions_seeing_cart    
select
	case 
		when created_at < '2013-09-25' then 'A. Pre_Cross_Sell'
        when created_at >= '2013-01-06' then 'B. Post_Cross_Sell'
        else '!'
	end as Time_period,
    website_session_id as cart_session_id,
    website_pageview_id as cart_pageview_id
from website_pageviews
where created_at between '2013-08-25' and '2013-10-25'
and pageview_url = '/cart' ;

select * from sessions_seeing_cart ;     

create temporary table cart_sessions_seeing_another_page
select
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    min(website_pageviews.website_pageview_id) as pv_id_ater_cart
from sessions_seeing_cart left join website_pageviews on sessions_seeing_cart.cart_session_id = website_pageviews.website_Session_id
and website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id
group by 1, 2
having min(website_pageviews.website_pageview_id) is not null ;

select * from cart_sessions_seeing_another_page ;

create temporary table pre_post_sessions_orders
select 
	Time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
from sessions_seeing_cart join orders on sessions_seeing_cart.cart_session_id = orders.website_session_id ;

select * from  pre_post_sessions_orders ;

select
	Time_period,
    count(distinct cart_session_id) as cart_sessions,
    sum(clicked_to_another_page) as clickthroughs,
    sum(clicked_to_another_page)/count(distinct cart_session_id) as cart_clr,
    sum(items_purchased)/sum(placed_order) as products_per_order,
    sum(price_usd)/sum(placed_order) as aov,
    sum(price_usd)/count(distinct cart_session_id) as rev_per_cart_session
from
(
select
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    case when cart_sessions_seeing_another_page.cart_session_id is null then 0 else 1 end as clicked_to_another_page,
    case when pre_post_Sessions_orders.order_id is null then 0 else 1 end as placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
from sessions_seeing_cart left join cart_sessions_seeing_another_page on sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
left join pre_post_sessions_orders on sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
order by cart_session_id 
) as full_data
group by Time_period ;

-- Product portfolio expansion --

select
	case 
		when website_sessions.created_at < '2013-12-12' then 'A. Pre_Birthday_Bear'
        when website_sessions.created_at >= '2013-12-12' then 'B. Post_Birthday_Bear'
        else '!'
	end as Time_period,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) as total_revenue,
    sum(orders.items_purchased) as total_products_sold,
    sum(orders.price_usd)/count(distinct orders.order_id) as average_order_value,
    sum(orders.items_purchased)/count(distinct orders.order_id) as products_per_order,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) as revenue_per_session
from website_Sessions left join orders on orders.website_Session_id = website_Sessions.website_Session_id
where website_Sessions.created_at between '2013-11-12' and '2014-01-12'
group by 1 ;

-- Analyzing product refund rates --

select product_id, product_name from products ;

select * from order_item_refunds 
where created_at < '2014-10-15' ;

select 
	year(order_items.created_at) as yr,
    month(order_items.created_at) as mo,
    count(case when order_items.product_id = 1 then order_items.order_item_id else null end) as p1_orders,
    count(case when order_items.product_id = 1 then order_item_refunds.order_item_id else null end)/count(case when order_items.product_id = 1 then order_items.order_item_id else null end) as p1_refund_rt,
	count(case when order_items.product_id = 2 then order_items.order_item_id else null end) as p2_orders,
    count(case when order_items.product_id = 2 then order_item_refunds.order_item_id else null end)/count(case when order_items.product_id = 2 then order_items.order_item_id else null end) as p2_refund_rt,
    count(case when order_items.product_id = 3 then order_items.order_item_id else null end) as p3_orders,
    count(case when order_items.product_id = 3 then order_item_refunds.order_item_id else null end)/count(case when order_items.product_id = 3 then order_items.order_item_id else null end) as p3_refund_rt,
    count(case when order_items.product_id = 4 then order_items.order_item_id else null end) as p4_orders,
    count(case when order_items.product_id = 4 then order_item_refunds.order_item_id else null end)/count(case when order_items.product_id = 4 then order_items.order_item_id else null end) as p4_refund_rt
from order_items left join order_item_refunds on order_items.order_item_id = order_item_refunds.order_item_id 
where order_items.created_at < '2014-10-15'
group by 1, 2 ;

-- Identifying repeat visitors --

create temporary table sessions_w_repeats
select
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    website_sessions.website_session_id
from
(
select
	user_id,
    website_Session_id
from website_Sessions
where created_at < '2014-11-01' and created_at >= '2014-01-01'
and is_repeat_session = 0
) as new_sessions
left join website_Sessions on website_sessions.user_id = new_sessions.user_id
and website_Sessions.is_repeat_session = 1
and website_sessions.website_session_id > new_sessions.website_session_id
and website_sessions.created_at < '2014-11-01' and website_sessions.created_at >= '2014-01-01' ;

select * from sessions_w_repeats ;

select
	repeat_sessions,
    count(distinct user_id) as users
    from
(
select
	user_id,
    count(distinct new_session_id) as new_Sessions,
    count(distinct website_session_id) as repeat_Sessions
from sessions_W_repeats
group by 1 
order by 3 desc
) as user_level
group by 1 ;

-- Analyzing time to repeat --

create temporary table sessions_w_repeats_for_time_diff
select
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    new_sessions.created_at as new_sessions_created_at,
    website_sessions.website_session_id as repeat_session_id,
    website_Sessions.created_at as repeat_session_created_at
from
(
select
	user_id,
    website_Session_id,
    created_at
from website_Sessions
where created_at < '2014-11-03' and created_at >= '2014-01-01'
and is_repeat_session = 0
) as new_sessions
left join website_Sessions on website_sessions.user_id = new_sessions.user_id
and website_Sessions.is_repeat_session = 1
and website_sessions.website_session_id > new_sessions.website_session_id
and website_sessions.created_at < '2014-11-03' and website_sessions.created_at >= '2014-01-01' ;

select * from sessions_w_repeats_for_time_diff ;     

create temporary table users_first_to_second
select
	user_id,
    datediff(second_session_created_at, new_sessions_created_at) as days_first_to_second_session
from
(
select 
	user_id,
    new_session_id,
    new_sessions_created_at,
    min(repeat_session_id) as second_Session_id,
    min(repeat_session_created_at) as second_Session_created_at
from sessions_w_repeats_for_time_diff
group by 1, 2, 3 
) as first_second ;

select * from users_first_to_second ;     

select
	avg(days_first_to_second_session) as avg_days_first_to_second,
    min(days_first_to_second_session) as min_days_first_to_second,
    max(days_first_to_second_session) as max_days_first_to_second
from users_first_to_second ;

-- Analyzing repeat channel behavior --

create temporary table a
select
	utm_source,
    utm_campaign,
    http_referer,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at < '2014-11-05' and created_at >= '2014-01-01'
group by 1,2,3
order by 4 desc ;

select * from a ;

select 
	case
		when http_referer is null then 'organic_Search'
		when utm_campaign = 'brand' then 'paid_brand'
        when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'direct_type_in'
        when utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_source = 'socialbook' then 'paid_social'
	else '!'
    end as channel_group,
    sum(new_Sessions) as new_sessions,
    sum(repeat_sessions) as repeat_sessions
from a 
group by 1
order by 3 desc ;

-- Analyzing new and repeat conversion rates --

select
	is_repeat_session,
    count(website_sessions.website_session_id) as sessions,
    count(order_id)/count(website_sessions.website_session_id) as conv_rate,
    sum(price_usd)/count(website_sessions.website_session_id) as rev_per_session
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at between '2014-1-1' and '2014-11-7'
group by 1 ;


-- Final Project --


-- 1 : Session and order volume trended by quarter --
        
select
	year(website_sessions.created_at) as 'Year',
    quarter(website_sessions.created_at) as 'Quarter',
    count(website_sessions.website_session_id) as Sessions,
	count(orders.order_id) as Orders
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id 
group by 1,2 ;

-- 2 : Quarterly data for session-to-order conversion rate, revenue per order and revenue per session --

select
	year(website_sessions.created_at) as 'Year',
    quarter(website_sessions.created_at) as 'Quarter',
	count(orders.order_id)/count(website_sessions.website_session_id) as 'Session to Order conversion rate',
    sum(orders.price_usd)/count(orders.order_id) as 'Revenue per order',
    sum(orders.price_usd)/count(website_sessions.website_session_id) as 'Revenue per session'
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id 
group by 1,2 ;

-- 3 : Quarterly view of orders from specific channels --

select
	utm_source,
    utm_campaign,
    http_referer
from website_sessions
group by 1, 2, 3 ;

select
	year(website_sessions.created_at) as 'Year',
    quarter(website_sessions.created_at) as 'Quarter',
    count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) as 'Gsearch nonbrand',
    count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end) as 'Bsearch nonbrand',
    count(case when utm_campaign = 'brand' then order_id else null end) as 'Brand overall',
    count(case when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then order_id else null end) as 'Organic search',
	count(case when http_referer is null then order_id else null end) as 'Direct type-in'
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id 
group by 1,2 ;

-- 4 : Overall session-to-order conversion rates for the above channels --

select
	year(website_sessions.created_at) as 'Year',
    quarter(website_sessions.created_at) as 'Quarter',
    count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end)/count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as 'Gsearch nonbrand conv rate',
    count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end)/count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as 'Bsearch nonbrand conv rate',
    count(case when utm_campaign = 'brand' then order_id else null end)/count(case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as 'Brand overall conv rate',
    count(case when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then order_id else null end)/count(case when utm_source is null and utm_campaign is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then website_sessions.website_session_id else null end) as 'Organic search conv rate',
	count(case when http_referer is null then order_id else null end)/count(case when http_referer is null then website_sessions.website_session_id else null end) as 'Direct type-in conv rate'
from website_sessions left join orders on website_sessions.website_session_id = orders.website_session_id 
group by 1,2 ;

-- 5 : Monthly trending for revenue and margin by product, along with total sales and revenue --

select pageview_url from website_pageviews group by 1 ;

	-- Revenue and Margin --

create temporary table a
select
	year(website_pageviews.created_at) as 'Year',
    month(website_pageviews.created_at) as 'Month',
	website_pageviews.pageview_url as Products,
    sum(price_usd) as Revenue,
    sum(price_usd - cogs_usd) as Margin
from website_pageviews left join orders on website_pageviews.website_Session_id = orders.website_session_id
where website_pageviews.pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear')
group by 1, 2, 3 ;

select * from a ;

	-- Total sales --

select
	website_pageviews.pageview_url as Products,
    count(orders.order_id) as 'Total Sales'
from website_pageviews left join orders on website_pageviews.website_Session_id = orders.website_session_id
where website_pageviews.pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda', '/the-hudson-river-mini-bear')
group by 1 ;

	-- Total revenue --

select
	sum(revenue) as 'Total Revenue'
from a ;

-- 6 : Monthly sessions to product page conversion rates along with conversion of products page to order page --

create temporary table product_pageviews
select
	website_session_id,
    website_pageview_id,
    created_at as saw_product_page_at
from website_pageviews
where pageview_url = '/products' ;

select
	year(saw_product_page_at) as 'Year',
    month(saw_product_page_at) as 'Month',
    count(distinct product_pageviews.website_session_id) as session_to_product_pageview,
    count(distinct website_pageviews.website_session_id) as clicked_to_next_page,
    count(distinct website_pageviews.website_session_id)/count(distinct product_pageviews.website_session_id) as clickthrough_rt,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct product_pageviews.website_session_id) as products_to_order_rt
from product_pageviews left join website_pageviews on website_pageviews.website_session_id = product_pageviews.website_session_id
and website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
left join orders on orders.website_session_id = product_pageviews.website_session_id
group by 1, 2 ;

-- 7 : How well each product cross-sells from one another since 5th December 2014 --

select * from orders
where created_at >= '2014-12-05' ;

select * from order_items
where created_at >= '2014-12-05' ;

create temporary table d 
select
	orders.order_id,
    orders.primary_product_id,
    case when order_items.is_primary_item = 0 then order_items.product_id else null end as Cross_sell_id
from orders left join order_items on orders.order_id = order_items.order_id
where orders.created_at >= '2014-12-05' ;

select * from d ;

select
	primary_product_id as Product_id,
    Cross_sell_id,
    count(order_id) as Orders
from d
group by 1, 2 
order by 3 desc ;

-- 8 : Recommendations and opportunities for company to grow --

		-- 1. Focus more on Quarter-3 as this quarter generates more sessions and orders due to festivity
        -- 2. Session to order conversion rates, revenue per order and revenue per session is constantly growing quarter on quarter
        -- 3. Focus more on Gsearch nonbrand channel as it help generates most orders
        -- 4. Conversion rate from sessions to orders is similar for all 3 - Brand, Organic search and Direct type-in
        -- 5. The-original-mr-fuzzy has highest sales till date - 23861, next is The-forever-love-bear at 4803. The-original-mr-fuzzy is a champion product
        -- 6. Total revenue of company till date is - $ 1938509.75
        -- 7. Both Sessions to product page conversion rate and Product page to order conversion rate has grown
        -- 8. Product_id - 1 alone sells the most at 4467, 2nd is Product_id - 2 at 1277, 3rd is Product_id - 1 along with Product_id - 4 at 933
        
    

    


    
























    
