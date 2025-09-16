select order_status, count(*) from orders
group by 1;

select * from orders where false;

select o.order_date,
round(sum(oi.order_item_subtotal)::numeric, 2) as order_revenue
from orders o
join order_items oi
on o.order_id = oi.order_item_order_id
where o.order_status in ('COMPLETE', 'CLOSED')
group by 1
order by 1;

create or replace table daily_revenue
as
select o.order_date,
round(sum(oi.order_item_subtotal)::numeric, 2) as order_revenue
from orders o
join order_items oi
on o.order_id = oi.order_item_order_id
where o.order_status in ('COMPLETE', 'CLOSED')
group by 1;

select * from daily_revenue;

create or replace table daily_product_revanue
as
select o.order_date,
oi.order_item_product_id,
round(sum(oi.order_item_subtotal):: numeric, 2) order_revenue
from orders o
join order_items oi
on o.order_id = oi.order_item_order_id
where o.order_status in ('COMPLETE', 'CLOSED')
group BY 1,2;

select * from daily_product_revanue
order by 1, 3 desc;

select  to_char(dr.order_date::timestamp, 'yyyy-MM') order_month,
sum(order_revenue) order_revenue
from daily_revenue dr
group by 1
order by 1;

select  to_char(dr.order_date::timestamp, 'yyyy-MM') order_month,
dr.order_date, dr.order_revenue,
sum(order_revenue) over
(partition by to_char(dr.order_date::timestamp, 'yyyy-MM')) monthly_order_revenue
from daily_revenue dr
order by 2;

select dr.*,
sum(order_revenue) over (partition by 1) total_order_revenue
from daily_revenue dr;

select count(*) from daily_product_revanue;

select * from daily_product_revanue
order by order_date, order_revenue desc;

select order_date, order_item_product_id, order_revenue,
rank() over(order by order_revenue desc) rnk,
dense_rank() over(order by order_revenue desc) drnk
from daily_product_revanue
where order_date = '2014-01-01 00:00:00.0'
order by order_revenue desc;

select to_char(order_date::date, 'yyyy-MM-dd') fecha, order_item_product_id, order_revenue,
rank() over(
  partition by order_date 
  order by order_revenue desc) rnk,
dense_rank() over(
  partition by order_date 
  order by order_revenue desc) drnk
from daily_product_revanue
where to_char(order_date::date,'yyyy-MM') = '2014-01'
order by order_date, order_revenue desc;

--Nested query --
select * from (
select order_date, order_item_product_id, order_revenue,
rank() over(order by order_revenue desc) rnk,
dense_rank() over(order by order_revenue desc) drnk
from daily_product_revanue
where order_date = '2014-01-01 00:00:00.0') q
where rnk <= 5;

--CTE--
with daily_prod_revenue_ranks as(
select order_date, order_item_product_id, order_revenue,
rank() over(order by order_revenue desc) rnk,
dense_rank() over(order by order_revenue desc) drnk
from daily_product_revanue
where order_date = '2014-01-01 00:00:00.0')
select * from daily_prod_revenue_ranks
where drnk <= 5
order by order_revenue desc;

select * from(
select to_char(order_date::date, 'yyyy-MM-dd') fecha, order_item_product_id, order_revenue,
rank() over(
  partition by order_date 
  order by order_revenue desc) rnk,
dense_rank() over(
  partition by order_date 
  order by order_revenue desc) drnk
from daily_product_revanue
where to_char(order_date::date,'yyyy-MM') = '2014-01') q
where drnk <= 5
order by fecha, order_revenue desc;

with daily_prod_revenue_ranks as(
select to_char(order_date::date, 'yyyy-MM-dd') fecha, order_item_product_id, order_revenue,
rank() over(
  partition by order_date 
  order by order_revenue desc) rnk,
dense_rank() over(
  partition by order_date 
  order by order_revenue desc) drnk
from daily_product_revanue
where to_char(order_date::date,'yyyy-MM') = '2014-01')
select * from daily_prod_revenue_ranks
where drnk <= 5
order by fecha, order_revenue desc;

create or replace table student_scores(
  student_id int primary key,
  student_score int
);

insert into student_scores values
(1,980),
(2,960),
(3,960),
(4,990),
(5,920),
(6,960),
(7,980),
(8,960),
(9,940),
(10,940);

select * from student_scores
order by student_score desc;

select student_id, student_score,
rank() over(order by student_score desc) rank,
dense_rank() over (order by student_score desc) drank 
from student_scores
order by student_score desc;