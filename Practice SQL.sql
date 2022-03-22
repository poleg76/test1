
 
 alter table orders add constraint orders_delivery_fkey foreign key (delivery_id) references delivery(delivery_id)
 
 
 insert into delivery (address_id , staff_id, delivery_date, delivery_time)
 values(100, 2, '2022.01.22', array['10:00:00','12:00:00']::time[]),
       (205, 2, '2022.01.23', array['16:00:00','18:00:00']::time[]),
       (17, 2, '2022.01.22', array['12:00:00','14:00:00']::time[])
       
       select * from delivery
       
 select * from orders 
 
 update orders 
 set delivery_id = 3
 where order_id = 1
 
 update orders 
 set delivery_id = 1
 where order_id = 2
 
 update orders 
 set delivery_id = 2
 where order_id = 3
 
 select * from customer 
 
 select * from delivery
 select * from product 
 select * from category
 select * from orders
 SELECT COUNT(*) FROM orders;

SELECT product, remains FROM product WHERE category_id = 62;
 
CREATE TABLE table_one (name_one VARCHAR(25) NOT NULL)
CREATE TABLE table_two (name_two VARCHAR(25) NOT NULL)
INSERT INTO table_one (name_one)VALUES ('one'), ('two'), ('three'), ('four'), ('five')
INSERT INTO table_two (name_two)VALUES ('four'), ('five'), ('six'), ('seven'), ('eight')

select * from table_two

drop TABLE table_one

SELECT category_id, SUM(remains)
FROM product  
GROUP BY category_id;

SELECT t1.name_one, t2.name_two
FROM table_one t1
LEFT JOIN table_two t2 ON t1.name_one = t2.name_two

join address a on c.address_id = a.address_id
join city ct on a.city_id = ct.city_id
join staff s on a.address_id =s.address_id

SELECT  product.category_id, category, SUM(product.remains)
FROM product 
JOIN category on product.category_id = category.category_id
GROUP by category.category_id;

SELECT DISTINCT max(count(*)) OVER() cat_count
FROM product 
JOIN category on product.category_id = category.category_id
group by category.category_id

SELECT category, count(*) cat_count
FROM product 
JOIN category on product.category_id = category.category_id
group by category.category_id


SELECT MAX(cat_count) 
FROM (SELECT count(*) cat_count FROM product 
JOIN category on product.category_id = category.category_id
group by category.category_id) X

SELECT category, count(*) cat_count
FROM product 
JOIN category on product.category_id = category.category_id
group by category.category_id
HAVING count(*)>=ALL(SELECT count(*) FROM product 
JOIN category on product.category_id = category.category_id
group by category.category_id)

SELECT category_id, SUM(remains) as "Количество товаров"
FROM product  
GROUP BY category_id;

select * from category
select * from customer 
select * from orders 
select * from product
select * from order_product_list

SELECT c.last_name as "ФАМИЛИЯ", c.first_name as "ИМЯ", p.product as "ТОВАР" 
FROM  orders o
join order_product_list opl on o.order_id = opl.order_id
join customer c on o.customer_id = c.customer_id 
join product p on p.product_id = opl.product_id WHERE c.first_name = 'Linda' 
--where p.product = 'Черепаха'
--JOIN order_product_list on orders.order_id  = order_product_list.order_id;
--JOIN customer on orders.customer_id = customer.customer_id; --WHERE first_name = 'Linda';
--JOIN product on product.product_id = order_product_list.product_id; --where product.product = 'Черепаха';

product.product as "ТОВАР" 
where customer.first_name = 'Linda' ;

SELECT *
FROM customer 
WHERE first_name = 'Linda'


-- Количество работающих со схемой delivery
select count(*)- 1 
from information_schema.tables t
where table_name = 'delivery'

select opl.order_id, opl.product_id, p.product 
from order_product_list opl
JOIN product p on opl.product_id = p.product_id where p.product = 'Черепаха';

select first_name, last_name 
from customer 
where address_id = (select address_id from customer where first_name  = 'Linda') 

-- Задание_2 ИГРУШКИ
select category.category_id, category as "категории", count(*) AS "количество"
FROM product 
JOIN category on product.category_id = category.category_id 
group by category.category_id HAVING category.category LIKE 'Игрушки'

--Задание_3 Линда-Черепахи
select concat(c.first_name,' ', c.last_name) as Покупатель, p.product as Товар, opl.amount as Количество
from orders o
join order_product_list opl on o.order_id = opl.order_id
join customer c on o.customer_id = c.customer_id 
join product p on p.product_id = opl.product_id
where first_name like('Linda') and p.product = 'Черепаха'

--Подзапросы
SELECT customer_id, SUM(amount) / (SELECT SUM(amount)
FROM orders)FROM orders
GROUP BY customer_id

--Найдем сумму платежей пользователей, чья фамилия начинается на А (с указанием ФИ).
SELECT o.customer_id, concat, SUM(amount)
FROM orders o
JOIN (SELECT customer_id,CONCAT(last_name,' ', first_name)
FROM customer WHERE left(last_name, 1) = 'A') t
ON t.customer_id = o.customer_id GROUP BY o.customer_id, concat

--Найдем сумму платежей пользователей, чья фамилия начинается на А (без указания фамилии).
SELECT customer_id, SUM(amount)
FROM orders 
WHERE customer_id IN (SELECT customer_id FROM customer WHERE LEFT(last_name, 1) = 'A')
GROUP BY customer_id

--Посмотрим на пример работы оконной функции ROW_NUMBER,
--которая нумерует строки в рамках окна.
--Пронумеруем заказы по каждому пользователю 
--в порядке возрастания платежей.
SELECT order_id, customer_id, amount, ROW_NUMBER()
OVER (PARTITION BY customer_id ORDER BY amount)
FROM orders
OFFSET 25

--Получим каждый 10 заказ пользователя в порядке идентификаторов заказов:
SELECT *FROM (SELECT order_id, customer_id, amount, 
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_id)FROM orders) t 
WHERE row_number % 10 = 0

--Получим данные по идентификатору заказа,
--идентификатору товара,
--идентификатору категории,
--сумме заказов по каждому товару и средней стоимости товаров
--в каждой категории:
SELECT o.order_id, p.product_id, p.category_id, SUM(o.amount) 
OVER (PARTITION BY p.product_id),ROUND(AVG(p.price)OVER (PARTITION BY p.category_id), 2)
FROM orders o 
JOIN order_product_list opl ON opl.order_id = o.order_id
JOIN product p ON p.product_id = opl.product_id
OFFSET 153

ПРЕДСТАВЛЕНИЯ

--Получим информацию по ФИО клиента,
--сумму платежей и количество товаров по каждой категории
--и разместим данный запрос в представление:

CREATE VIEW customers_sum_avg as 
SELECT c.last_name, c.first_name, c2.category, SUM(o.amount), COUNT(o.order_id)
FROM orders o 
JOIN order_product_list opl ON opl.order_id = o.order_id 
JOIN product p ON p.product_id = opl.product_id
JOIN category c2 ON c2.category_id = p.category_id
JOIN customer c ON c.customer_id = o.customer_id
GROUP BY c.last_name, c.first_name, o.customer_id, p.category_id, c2.category
ORDER BY o.customer_id
--теперь нам достаточно выполнить запрос
SELECT * FROM customers_sum_avg

--с использованием Limit
select c.category
from category c
where c.category_id= (select t.category_id
from (select count (p.category_id), p.category_id
from product p
group by p.category_id
order by count desc
limit (1)
) t
)

--Практика использования Limit является корректной,
-- упросить запрос можно убрав подзапросы, например:
select count(p.product_id), c.category
from product p
join category c on p.category_id = c.category_id
group by c.category
order by count desc
LIMIT (1)

--с кем живет, но только из работников
select s.last_name, s.first_name
from customer c
join staff s on c.address_id = s.address_id
where c.last_name =‘Williams’ and c.first_name =‘Linda’

--объединение двух таблиц через Union,
-- с помощью подзапросов вычислить address_id где живет Williams Linda и отфильтровать всех людей живущих по данному адресу.
select last_name,first_name
from customer c
where c.address_id =
(select address_id
from customer c
where c.last_name ='Williams' and c.first_name ='Linda')
union all select s.last_name, s.first_name
from staff s
where s.address_id =
(select address_id
from customer c2
where c2.last_name ='Williams' and c2.first_name ='Linda')
--Сколько “Черепах” купила Williams Linda?
SELECT count(product)
FROM product p
JOIN order_product_list opl ON p.product_id =opl.product_id
JOIN orders o ON o.order_id =opl.order_id
JOIN customer c ON o.customer_id =c.customer_id
WHERE c.first_name LIKE 'Linda' AND c.last_name LIKE 'Williams' AND p.product LIKE 'Черепаха'
