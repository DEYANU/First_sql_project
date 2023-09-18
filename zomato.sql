drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'22-09-2017'),
(3,'21-04-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'02-09-2014'),
(2,'15-01-2015'),
(3,'11-04-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'19-04-2017',2),
(3,'18-12-2019',1),
(2,'20-07-2020',3),
(1,'23-10-2019',2),
(1,'19-03-2018',3),
(3,'20-12-2016',2),
(1,'09-11-2016',1),
(1,'20-05-2016',3),
(2,'24-09-2017',1),
(1,'11-03-2017',2),
(1,'11-03-2016',1),
(3,'10-11-2016',1),
(3,'07-12-2017',2),
(3,'15-12-2016',2),
(2,'08-11-2017',2),
(2,'10-09-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from users;
select * from sales order by created_date;
select * from product;
select * from goldusers_signup;

1. What is the total amount each customer spent on zomato?

select a.userid, sum(b.price)
from sales as a 
inner join  product as b on a.product_id=b.product_id
group by a.userid order by sum(b.price) desc;

2. How many days has each customer visited zomato?

select userid,count(distinct(created_date)) as total_days from sales
group by userid;

3. What was the first product purchased by each customer?

select * from (select *, rank() over(partition by userid order by created_date ) as rank from sales) new_table where rank=1;


4. What is the most purchased item in the menu, and how many times it has been bought by each the customers?


select userid,count(product_id) from sales where product_id=
(select product_id from sales 
group by product_id order by count(created_date) desc limit 1)
group by userid;

5. Which item is the most populer for each customer?

select * from (select *,rank() over (partition by userid order by cnt desc) as rnk from 
(select userid,product_id,count(product_id) as cnt from sales 
group by userid,product_id) as b)as derived_table where rnk=1;

6. What was the first product purchased by each customer after they became gold member?

select * from
(select *,rank() over (partition by userid order by created_date asc) as rnk from
(select a.userid, a.product_id,a.created_date, b.gold_signup_date from sales a
inner join goldusers_signup b on a.userid= b.userid and a.created_date>b.gold_signup_date) as a)as b 
where rnk=1;

7. What was the last product purchased by each customer before they became gold member?

select * from
(select *,rank() over (partition by userid order by created_date desc) as rnk from
(select a.userid, a.product_id,a.created_date, b.gold_signup_date from sales a
inner join goldusers_signup b on a.userid= b.userid and a.created_date<b.gold_signup_date) as a)as b 
where rnk=1;

8. What is the total orders and amount spent for each member before they became golden member?


select userid, count(created_date), sum(price) from
(select c.*,d.price from
(select a.userid, a.product_id,a.created_date from sales a
inner join goldusers_signup b on a.userid= b.userid and a.created_date<b.gold_signup_date) c 
inner join product d on c.product_id=d.product_id) e
group by userid;

9. If buying each products generates points for eg p1: 5rs= 1 Point, p2: 10rs= 5 Point 
and p3: 5rs= 1 Point

calculate points collected by each customer?

select e.*, (sum/points) as total_points from
(select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5
else 0 end as points
from (select userid,product_id, sum(price) from
(select a.userid,a.product_id, b.price from sales a inner join product b 
 on a.product_id=b.product_id) c 
 group by userid,product_id order by userid)d)e;


10. In the 1st one year after the customer joins gold membership 
irrespective of what the customer has purchased they earn 5 points for every 10 rs spent, 
and which customer earned more and what was their point earning in 1st year?


select *,(price/2) as zomato_points from
(select c.*, d.price from 
(select a.userid,a.created_date,a.product_id, b.gold_signup_date from sales a inner join goldusers_signup b
on a.userid=b.userid and a.created_date>= b.gold_signup_date 
and a.created_date<=b.gold_signup_date+365) c inner join product d on c.product_id=d.product_id) e;

11. Rank all the transactions for each customers.

select *, rank() over(partition by userid order by created_date) as rnk from sales;

12. Rank all transactions for each member from when they have became gold member 
and for every non gold member mark na.


select d.*, case when rnk=0 then 'na' else cast(rnk as varchar) end as new_rank from
(select c.*, cast(case when gold_signup_date is null then 0 
else rank() over (partition by userid order by created_date desc) end as varchar) as rnk from
(select a.*,b.gold_signup_date from sales a left join goldusers_signup b on a.userid=b.userid 
and a.created_date>=b.gold_signup_date) c) d;








