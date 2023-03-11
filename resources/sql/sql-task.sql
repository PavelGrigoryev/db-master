--Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT model ->> 'ru' AS model,
       fare_conditions,
       count(seat_no) AS number_of_seats
FROM aircrafts_data
         JOIN seats ON aircrafts_data.aircraft_code = seats.aircraft_code
GROUP BY model, fare_conditions
ORDER BY model;

--Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT model ->> 'ru' AS model,
       count(seat_no) AS number_of_seats
FROM aircrafts_data
         JOIN seats ON aircrafts_data.aircraft_code = seats.aircraft_code
GROUP BY aircrafts_data.aircraft_code
ORDER BY number_of_seats DESC
LIMIT 3;

--Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT aircrafts_data.aircraft_code,
       model ->> 'ru' AS model,
       seat_no
FROM aircrafts_data
         JOIN seats ON aircrafts_data.aircraft_code = seats.aircraft_code
WHERE model ->> 'ru' = 'Аэробус A321-200'
  AND fare_conditions != 'Economy'
ORDER BY seat_no;

--Вывести города в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airport_code,
       airport_name ->> 'en' AS name,
       city ->> 'ru'         AS city
FROM airports_data
WHERE city IN (SELECT city
               FROM airports_data
               GROUP BY city
               HAVING count(*) > 1)
ORDER BY city;

--Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT flight_id,
       dep.city ->> 'ru' AS departure,
       arr.city ->> 'ru' AS arrival,
       status
FROM flights
         JOIN airports_data AS dep ON flights.departure_airport = dep.airport_code
         JOIN airports_data AS arr ON flights.arrival_airport = arr.airport_code
WHERE dep.city ->> 'ru' = 'Екатеринбург'
  AND arr.city ->> 'ru' = 'Москва'
  AND flights.status NOT IN ('Departed', 'Arrived', 'Cancelled')
  AND scheduled_departure > bookings.now()
ORDER BY scheduled_departure
LIMIT 1;

--Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
SELECT concat('Cheapest #', min_tecket_no, ', price = ', min_amount)  AS cheapest,
       concat('Expensive #', max_ticket_no, ', price = ', max_amount) AS expensive
FROM (SELECT ticket_no AS min_tecket_no,
             amount    AS min_amount
      FROM ticket_flights
      ORDER BY amount
      LIMIT 1) AS min,
     (SELECT ticket_no AS max_ticket_no,
             amount    AS max_amount
      FROM ticket_flights
      ORDER BY amount DESC
      LIMIT 1) AS max;

--Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone. Добавить ограничения на поля (constraints)
CREATE TABLE customers
(
    id        SERIAL PRIMARY KEY,
    firstName VARCHAR(20) NOT NULL,
    lastName  VARCHAR(20) NOT NULL,
    email     VARCHAR(30) NOT NULL UNIQUE,
    phone     VARCHAR(20) NOT NULL CHECK (phone LIKE '+%')
);

--Написать DDL таблицы Orders , должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + ограничения
CREATE TABLE orders
(
    id         SERIAL PRIMARY KEY,
    customerId INTEGER NOT NULL REFERENCES customers (id),
    quantity   INTEGER NOT NULL CHECK (quantity > 0)
);

--Написать 5 insert в эти таблицы
INSERT INTO customers (firstName, lastName, email, phone)
VALUES ('Peter', 'Jackson', 'jaksy@gmail.com', '+375894589632');
INSERT INTO customers (firstName, lastName, email, phone)
VALUES ('Sveta', 'Ivanova', 'ivanRules@yandex.ru', '+375292236589');
INSERT INTO customers (firstName, lastName, email, phone)
VALUES ('Boby', 'Brown', 'browny_bob@mail.edu', '+375896548932');
INSERT INTO customers (firstName, lastName, email, phone)
VALUES ('Suzy', 'Jonce', 'susanna@yahoo.com', '+375986665478');
INSERT INTO customers (firstName, lastName, email, phone)
VALUES ('Anna', 'Shlapnikova', 'megakiller666@gmail.com', '+375333658863');

INSERT INTO orders (customerId, quantity)
VALUES (1, 11);
INSERT INTO orders (customerId, quantity)
VALUES (4, 7);
INSERT INTO orders (customerId, quantity)
VALUES (3, 4);
INSERT INTO orders (customerId, quantity)
VALUES (2, 2);
INSERT INTO orders (customerId, quantity)
VALUES (5, 1200);

--Удалить таблицы
DROP TABLE orders, customers;

--Написать свой кастомный запрос (rus + sql)
--Вывести пассажиров с посадочным номером 120, общая сумма которых меньше 10 тысяч и дата бронирования за 2017-07-31
SELECT board.boarding_no,
       tickets.ticket_no,
       passenger_name,
       book.total_amount
FROM tickets
         JOIN bookings AS book ON tickets.book_ref = book.book_ref
         JOIN boarding_passes AS board ON tickets.ticket_no = board.ticket_no
WHERE board.boarding_no = 120
  AND book.total_amount < 10000
  AND date(book.book_date) = date('2017-07-31');
