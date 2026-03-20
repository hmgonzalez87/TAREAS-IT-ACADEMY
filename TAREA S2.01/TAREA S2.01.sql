SHOW tables;

SELECT * FROM company;

SELECT * FROM transaction;

SELECT company_name, email, COUNT(*)
FROM company
GROUP BY company_name, email
HAVING COUNT(*) > 1;

SELECT id, COUNT(*)
FROM transaction
GROUP BY id
HAVING COUNT(*) > 1;

-- NIVEL 1:

-- 2.1 Listado de los países que están generando ventas.

SELECT DISTINCT c.country FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

-- 2.2 Desde cuántos países se generan las ventas.

SELECT COUNT(DISTINCT c.country ) AS number_countries FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

-- 2.3 Identifica a la compañía con la mayor media de ventas.

WITH company_avg AS (SELECT c.company_name, AVG(t.amount) AS avg_amount -- OPCION CON CTE
                     FROM company c
                     JOIN transaction t ON c.id = t.company_id
                     WHERE t.declined = 0
                     GROUP BY c.company_name)
SELECT company_name, ROUND(avg_amount, 2) AS sales_average
FROM company_avg
WHERE avg_amount = (SELECT MAX(avg_amount) FROM company_avg);

SELECT c.company_name, ROUND(AVG(t.amount), 2) AS sales_average FROM company c -- OPCION CON LIMIT
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY sales_average DESC
LIMIT 1;

-- 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT t.* FROM transaction t                  
WHERE t.company_id IN (SELECT id FROM company c
					 WHERE c.country = 'Germany');
                                        
-- 3.2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT c.company_name FROM company c
WHERE id IN (SELECT t.company_id FROM transaction t
             WHERE t.amount > (SELECT AVG(t2.amount) FROM transaction t2
							 WHERE t2.declined = 0)
			 AND declined = 0);
             
           
-- 3.3 Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT c.company_name, c.id FROM company c
WHERE NOT EXISTS (SELECT 1 FROM transaction t
			      WHERE c.id = t.company_id
                  AND t.declined <> 1);
                  
-- NIVEL 2:

-- 2.1 Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(timestamp) AS fecha, SUM(amount) AS total_ventas FROM transaction
WHERE declined = 0
GROUP BY fecha
ORDER BY total_ventas DESC
LIMIT 5;

-- 2.2 ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country, ROUND(AVG(t.amount), 2) AS venta_media FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY venta_media DESC;

-- 2.3 En tu empresa, se plantea un nuevo proyecto para lanzar campañas publicitarias para hacer competencia a la compañía “Non Institute”.
-- La lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.

-- 2.3.1 JOIN + SUBQUERY

SELECT t.id FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE c.country IN (SELECT country FROM company
                   WHERE company_name = 'Non Institute')
     AND c.company_name <> 'Non Institute'            -- SE EXCLUYE A LA MISMA EMPRESA
	 AND t.declined = 0;
     
-- 2.3. SUBQUERY

SELECT t.id FROM transaction t
WHERE EXISTS (SELECT 1 FROM company c
                   WHERE t.company_id = c.id
                   AND c.country IN (SELECT country FROM company
                                     WHERE company_name = 'Non Institute'
                   AND c.company_name <> 'Non Institute'))
AND t.declined = 0;
                   
-- NIVEL 3:

-- 3.1 Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido 
-- entre 350 y 400 euros y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena de mayor a menor cantidad.

SELECT c.company_name, c.phone,c.country, t.timestamp, t.amount FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
  AND t.declined = 0                  
  AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;

-- 3.2 Piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es 
-- exigente y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.

SELECT c.company_name, COUNT(t.id) AS total_transacciones,
    CASE 
        WHEN COUNT(t.id) > 400 THEN 'Más de 400'
        ELSE '400 o menos'
    END AS clasificacion
FROM company c
JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY total_transacciones DESC;