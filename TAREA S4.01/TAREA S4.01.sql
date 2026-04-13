CREATE DATABASE payments;
	
USE payments;
-- ------------------ CREACION DE LA TABLA transaction ----------- 
CREATE TABLE IF NOT EXISTS transactions(
	id VARCHAR(255),
    card_id VARCHAR(25),
    business_id VARCHAR(255),
    timestamp VARCHAR(25),
    amount VARCHAR(25),
    declined VARCHAR(25),
    products_id VARCHAR(25),
    user_id VARCHAR(15),
	lat VARCHAR(50),
    longitude VARCHAR(50)
 );
 
SHOW VARIABLES LIKE 'secure_file_priv';        -- MUESTRA DONDE GUARDAR LOS ARCHIVOS CSV PARA IMPORTARLOS
 
LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//transactions.csv' -- CARGAR ARCHIVO CSV
INTO TABLE transactions
FIELDS TERMINATED BY ';'    -- OJOOOOOOO: PUEDE SER , O ;
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM transactions;

-- ----------------------- ANALISIS DE LOS DATOS ------------------

WITH buscar_duplic AS        -- BUSCAR DUPLICADOS
(SELECT *, 
ROW_NUMBER() OVER(PARTITION BY id, card_id, business_id, timestamp, amount, declined, products_id, user_id, lat, longitude) AS num_reg
FROM transactions
)
SELECT * FROM buscar_duplic       
WHERE num_reg > 1;

SELECT id, COUNT(*) AS Cant_veces FROM transactions -- SI id es la PK busco solo duplicados por id
GROUP BY id
HAVING COUNT(*) > 1;
SELECT * FROM TRANSACTIONS;

CREATE TABLE IF NOT EXISTS transaction(
	id VARCHAR(255) NOT NULL PRIMARY KEY,
    card_id VARCHAR(25),
    business_id VARCHAR(25),
    timestamp DATETIME,
    amount DECIMAL(10, 2),
    declined TINYINT,
    products_id VARCHAR(25),
    user_id INT,
	lat DECIMAL(10, 6),
    longitude DECIMAL(10, 6)
 );
 
INSERT INTO transaction (id, card_id, business_id, timestamp, amount, declined, products_id, user_id, lat, longitude)
SELECT 
	TRIM(id),
    card_id,
    LEFT(business_id, 25),
    STR_TO_DATE(timestamp, '%Y-%m-%d %H:%i:%s'),
    CAST(amount AS DECIMAL(10,2)),
    CAST(declined AS SIGNED),
    products_id, 
    CAST(user_id AS SIGNED),
    CAST(lat AS DECIMAL(10,6)),
    CAST(longitude AS DECIMAL(10,6))
FROM transactions;
    
SELECT * FROM transaction;

ALTER TABLE transaction                   -- MODIFICAR EL NOMBRE DEL CAMPO PARA CONSISTENCIA CON LA TABLA companies
RENAME COLUMN business_id to company_id;

SELECT * FROM transaction;

DROP TABLE transactions;
	   	
-- ------------------ CREACION DE LA TABLA company ----------- 

CREATE TABLE IF NOT EXISTS companies(
	company_id VARCHAR(15),
    company_name VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(50),
    country VARCHAR(50),
    website VARCHAR(50)
 );
 
LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//companies.csv' -- CARGAR ARCHIVO CSV
INTO TABLE companies
FIELDS TERMINATED BY ','              
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ----------------------- ANALISIS DE LOS DATOS ------------------ 

SELECT company_id, COUNT(*) AS Cant_veces FROM companies      -- VERIFICAR SI HAY DUPLICADOS
GROUP BY company_id
HAVING COUNT(*) > 1 ;

SELECT DISTINCT company_name     -- CHEQUEAR SI HAY ERRORES EN LOS NOMBRES
FROM companies;

UPDATE companies             -- ELIMINAR EL (.) FINAL DE ALGUNAS COMPAÑIAS
SET company_name = TRIM(TRAILING '.' FROM company_name)
WHERE company_name LIKE '%.' AND company_id IS NOT NULL;

ALTER TABLE companies             -- RENOMBRAR EL NOMBRE DEL CAMPO
RENAME COLUMN company_id to id;

SELECT * FROM companies;

CREATE TABLE IF NOT EXISTS company (         -- TABLA FINAL
	id VARCHAR(25) NOT NULL PRIMARY KEY, 
    company_name VARCHAR(50), 
    phone VARCHAR(25), 
    email VARCHAR(50) UNIQUE, 
    country VARCHAR(50), 
    website VARCHAR(50)
);

INSERT INTO company (id, company_name, phone, email, country, website)
SELECT id, company_name, phone, email, country, website
FROM companies;

DROP TABLE companies;

SELECT * FROM company;

-- ------------------ CREACION DE LA TABLA credit_card ----------- 

CREATE TABLE IF NOT EXISTS credit_cards(
	id VARCHAR(20),
    user_id VARCHAR(50),
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(15)
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//credit_cards.csv' -- CARGAR ARCHIVO CSV
INTO TABLE credit_cards
FIELDS TERMINATED BY ','              
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM credit_cards;

CREATE TABLE IF NOT EXISTS credit_card(    -- Tabla final donde no tengo los campos track1, track2.
	id VARCHAR(20) NOT NULL PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(35),
    pin CHAR(4),
    cvv CHAR(3),
    expiring_date DATE
);

INSERT INTO credit_card (id, user_id, iban, pan, pin, cvv, expiring_date)
SELECT 
	id,
    CAST(user_id AS SIGNED),
    iban,
    LEFT (pan, 35),
    CAST(pin AS CHAR(4)),
    CAST(cvv AS CHAR(3)),
    STR_TO_DATE (expiring_date, '%m/%d/%y')
FROM credit_cards;

DROP TABLE credit_cards;
    
-- ------------------ CREACION DE LA TABLA data_user ----------- 

CREATE TABLE IF NOT EXISTS american_users(            -- TABLA american_users
	id VARCHAR(20),
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(50),
    birth_day VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(15),
    address VARCHAR(50)
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//american_users.csv' -- CARGAR ARCHIVO CSV
INTO TABLE american_users
FIELDS TERMINATED BY ','              
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;	

SELECT * FROM american_users;

-- ----------------------- ANALISIS DE LOS DATOS ------------------ 

UPDATE american_users
SET phone = CONCAT(
  '+1',
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(phone, '+1', ''),
        ' ', ''),
      '-', ''),
    '(', ''),
  ')', '')
)
WHERE phone IS NOT NULL;

UPDATE american_users
SET phone = REPLACE(phone, '+11', '+1');

ALTER TABLE american_users              -- RENOMBRAR LA COLUMNA
RENAME COLUMN birth_day TO birth_date;

UPDATE american_users                                         -- CONVIERTO COLUMNA A DATE
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y');

SELECT * FROM american_users;

CREATE TABLE IF NOT EXISTS european_users(               -- TABLA european_users
	id VARCHAR(20),
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(50),
    birth_date VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(15),
    address VARCHAR(50)
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//european_users.csv' -- CARGAR ARCHIVO CSV
INTO TABLE european_users
FIELDS TERMINATED BY ','              
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM european_users;

-- ----------------------- ANALISIS DE LOS DATOS ------------------ 

UPDATE european_users                                         -- CONVIERTO COLUMNA A DATE
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y');

UPDATE european_users                             -- Estandarizar campo phone
SET phone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone, '+', ''),' ', ''),'-', ''),'(', ''),')', '');

CREATE TABLE IF NOT EXISTS data_user(               -- TABLA FINAL
	id INT NOT NULL PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(50),
    email VARCHAR(50),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(15),
    address VARCHAR(50)
);

INSERT INTO data_user (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
SELECT CAST(id AS SIGNED), name, surname, phone, email, birth_date, country, city, postal_code, address
FROM european_users
UNION ALL
SELECT CAST(id AS SIGNED), name, surname, phone, email, birth_date, country, city, postal_code, address
FROM american_users;

DROP TABLE american_users, european_users;  -- ELIMINO TABLAS STAGING


-- --------- CREAR LAS FOREIGN KEYS ---------------------------------------------------

ALTER TABLE transaction
ADD CONSTRAINT fk_company
FOREIGN KEY(company_id) REFERENCES company(id),
ADD CONSTRAINT fk_data_user
FOREIGN KEY(user_id) REFERENCES data_user(id),
ADD CONSTRAINT fk_credit_card
FOREIGN KEY(card_id) REFERENCES credit_card(id);

SELECT                -- SOLO PARA SABER LAS FK DE UNA TABLA ESPECIFICA.
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_NAME = 'transaction'
    AND TABLE_SCHEMA = 'payments'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ---------------------------- NIVEL 1 ----------------------------------------------

-- 1-) Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones

SELECT d.*
FROM data_user d
JOIN (SELECT user_id, COUNT(*) AS Cant_trasacc 
	  FROM transaction
	  WHERE declined =0
      GROUP BY user_id
      HAVING COUNT(id) > 80) AS t
ON d.id = t.user_id;

-- 2-) Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd.

SELECT cc.iban, ROUND(AVG(t.amount), 2) AS Average FROM credit_card cc
JOIN transaction t ON cc.id = t.card_id
JOIN company c ON t.company_id = c.id
WHERE c.company_name = 'Donec Ltd' AND t.declined = 0
GROUP BY cc.iban;

-- ---------------------------- NIVEL 2 ----------------------------------------------

SELECT d.card_id, COUNT(*) AS Cant                 -- OBTENGO LAS TARJETAS QUE CUMPLEN CON ACTIVA + CANT
FROM (SELECT t.card_id, t.id, t.declined
      FROM (SELECT card_id, id, declined,
            ROW_NUMBER () OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking
	        FROM transaction) AS t
      WHERE ranking <= 3) AS d
WHERE declined = 0
GROUP BY d.card_id
HAVING COUNT(*) > 0; 

CREATE TABLE IF NOT EXISTS card_status(
	id INT AUTO_INCREMENT PRIMARY KEY,
    card_id VARCHAR(20),
    status VARCHAR(50) CHECK(status IN('active', 'inactive')),
    CONSTRAINT fk_credit_card2
    FOREIGN KEY(card_id) REFERENCES credit_card(id)
);

INSERT INTO card_status (card_id, status)
SELECT card_id,
       CASE 
           WHEN MIN(declined) = 0 THEN 'active'
           ELSE 'inactive'
       END AS status
FROM (
    SELECT card_id, declined,
           ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking
    FROM transaction) AS t
WHERE ranking <= 3
GROUP BY card_id;

-- 1-) ¿Cuántas tarjetas están activas?

SELECT COUNT(*) AS Num_active FROM card_status
WHERE status = 'active';

-- ---------------------------- NIVEL 3 ----------------------------------------------

CREATE TABLE IF NOT EXISTS products(
	id VARCHAR(25) NOT NULL PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    color VARCHAR(25),
    weight DECIMAL(10,2),
    warehouse VARCHAR(15)
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.4//Uploads//products.csv' -- CARGAR ARCHIVO CSV
INTO TABLE products
FIELDS TERMINATED BY ','              
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, product_name, @price, color, @weight, warehouse)                              -- SE PONEN TODOS LOS CAMPOS Y COLUMNAS TEMPORALES (@ + SET)
SET 
price = CAST(REPLACE(@price, '$', '') AS DECIMAL(10, 2)),
weight = CAST(@weight AS DECIMAL(10, 2));

SELECT * FROM transaction;

CREATE TABLE IF NOT EXISTS transaction_product(                    -- SE CREA TABLA INTERMEDIA PARA RELACION N:M
	transaction_id VARCHAR(255),
    products_id VARCHAR(25),
    PRIMARY KEY(transaction_id, products_id),
    CONSTRAINT fk_trasaction
		FOREIGN KEY(transaction_id) REFERENCES transaction(id),
    CONSTRAINT fk_products
		FOREIGN KEY(products_id) REFERENCES products(id)
 );
 
INSERT INTO transaction_product (transaction_id, products_id)
	SELECT t.id, p.id FROM transaction t
	JOIN products p ON FIND_IN_SET (p.id, REPLACE (t.products_id, ' ', ''));  -- ELIMINO ESPACIOS ENTRE (,)

-- 1-) Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT p.id, p.product_name, COUNT(tp.products_id) AS Num_times FROM products p
JOIN transaction_product tp ON p.id = tp.products_id
JOIN transaction t ON tp.transaction_id = t.id
WHERE t.declined = 0
GROUP BY p.id, p.product_name
ORDER BY Num_times DESC;


