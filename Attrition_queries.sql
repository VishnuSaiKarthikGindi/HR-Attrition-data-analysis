CREATE DATABASE practicedatabase;

USE practicedatabase;

CREATE TABLE brands(
category VARCHAR(255),
brand_name VARCHAR(255)
);

INSERT INTO brands
VALUES ('chocolate', '5-star'),
       (NULL, 'dairymilk'),
       (NULL, 'perk'),
       (NULL, 'eclair'),
       ('Biscuits', 'Britania'),
       (NULL, 'goodday'),
       (NULL, 'boost');

SELECT * FROM brands;

WITH cte AS(
SELECT *, ROW_NUMBER() OVER (ORDER BY(SELECT NULL)) AS rnum FROM brands),
cte2 AS(
SELECT *, COUNT(category) OVER (ORDER BY rnum) AS cnt FROM cte)
SELECT FIRST_VALUE(category) OVER (PARTITION BY cnt ORDER BY rnum) AS category, brand_name from cte2;

