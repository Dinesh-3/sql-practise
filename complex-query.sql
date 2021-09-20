USE sql_invoicing;

-- select invoice larger than all invoices of client 3
SELECT * FROM invoices
WHERE invoice_total > (
SELECT MAX(invoice_total) FROM invoices
WHERE client_id = 3
);

-- Above question using ALL keyword
-- If sub query returns more than one result comparison not work so we need to add ALL or ANY
SELECT * FROM invoices
WHERE invoice_total > ALL ( -- It's look like ALL (1761, 232) Also we have ANY
SELECT invoice_total FROM invoices
WHERE client_id = 3
);

-- Select All clients who's having atleast given invoices
USE sql_invoicing;
SELECT * FROM clients
WHERE client_id IN ( -- IN or = ANY (Both same)
	SELECT client_id FROM invoices
    GROUP BY client_id
    HAVING COUNT(*) >= 2
);

-- Get employees who's salary is above the average in their office
-- Correlated sub queries will execute every record in parent 

USE sql_hr;
SELECT * FROM employees e
WHERE salary > (
	SELECT avg(salary) 
    FROM employees
    WHERE office_id = e.office_id
);

-- select invoices that are larger than 
-- that client's average invoice total using correlated subquery
USE sql_invoicing;

SELECT * FROM invoices i
WHERE invoice_total > (
	SELECT AVG(invoice_total)
	FROM invoices
    WHERE client_id = i.client_id
)

USE sql_invoicing;

-- get clients who's have an invoice
SELECT * FROM clients c
WHERE client_id IN ( -- less efficient
	SELECT client_id FROM invoices
    WHERE c.client_id = client_id
);

USE sql_invoicing;
SELECT * FROM clients c
WHERE EXISTS ( -- more efficient it doesn't return actual result it return boolean
	SELECT client_id FROM invoices
    WHERE c.client_id = client_id
);

-- END --

USE sql_store;

SELECT * FROM products p
WHERE NOT EXISTS(
	SELECT DISTINCT product_id -- To get distinct product id
	FROM order_items
    WHERE p.product_id = product_id
);

-- END --

-- Get invoice total difference from average invoice total 
USE sql_invoicing;

SELECT invoice_id, 
  invoice_total, 
  (
    SELECT AVG(invoice_total) FROM invoices
  ) AS average_total,
  invoice_total - ( SELECT average_total ) AS difference

FROM invoices;

-- END --

USE sql_invoicing;

-- get user total spend on invoice (sum of invoice for each user) 
-- with difference between sum of invoice and invoices total average

-- approach 1 using join
SELECT  c.name,
		c.client_id,
    SUM(invoice_total),
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    SUM(invoice_total) - (SELECT average) AS difference
	
FROM invoices
RIGHT JOIN clients c 
	USING(client_id)
GROUP BY client_id;

-- approach 2 using subquery
USE sql_invoicing;

SELECT c.client_id,
		c.name,
    (SELECT SUM(invoice_total) FROM invoices i WHERE c.client_id = client_id) AS invoice_total,
    (SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT invoice_total - average) AS difference

FROM clients c;

-- END --
-- sub query in FROM clause

USE sql_invoicing;

SELECT * 

FROM (
	SELECT c.client_id,
		c.name,
        (SELECT SUM(invoice_total) FROM invoices i WHERE c.client_id = client_id) AS invoice_total,
        (SELECT AVG(invoice_total) FROM invoices) AS average,
        (SELECT invoice_total - average) AS difference
	FROM clients c
) AS sales_summary

WHERE invoice_total IS NOT NULL
;

-- END --