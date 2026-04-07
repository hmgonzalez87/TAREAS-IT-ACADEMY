SHOW tables;

show create table company;

show create table transaction;

-- NIVEL 1 

-- 1-) Tu tarea es diseñar y crear una tabla llamada "credit_card"...

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(15) NOT NULL PRIMARY KEY,
    iban VARCHAR (34) NOT NULL UNIQUE ,
    pan VARCHAR(16) NOT NULL UNIQUE ,
    pin CHAR(4) NOT NULL CHECK (pin REGEXP '^[0-9]{4}$'),
    cvv CHAR(3) NOT NULL CHECK (cvv REGEXP '^[0-9]{3}$'),
    expiring_date DATE NOT NULL
)ENGINE=InnoDB;

ALTER TABLE credit_card    -- MODIFICAR EL FORMATO DE expiring_date
MODIFY COLUMN expiring_date VARCHAR(10) NOT NULL;

ALTER TABLE credit_card    -- PARA SOLVENTAR CANTIDAD DE CARACTERES EN EL pan
MODIFY COLUMN pan VARCHAR(25) NOT NULL;

-- UPDATE credit_card                                             PRIMERO SERIA MODIFICAR DATOS DENTRO DE LA COLUMNA DE STRING TO DATE
-- SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

-- ALTER TABLE credit_card                LUEGO EL TIPO DE COLUMNA
-- MODIFY expiring_date DATE NOT NULL;


ALTER TABLE transaction  -- AGREGAR NUEVA CLAVE FORANEA
ADD CONSTRAINT fk_credit_card
FOREIGN KEY(credit_card_id) REFERENCES credit_card(id)
ON DELETE CASCADE
ON UPDATE CASCADE; 

SELECT                     -- MUESTRA TODAS LAS FK DE LA BASE DE DATOS
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'transactions'
    AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 2-) La información que debe mostrarse para este registro es: TR323456312213576817699999.

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban FROM credit_card
WHERE id = 'CcU-2938'; 

-- 3-) En la tabla "transaction" ingresa una nueva transacción con la siguiente información:

INSERT INTO company (id) VALUES ('CcU-9999');  -- company_id ES FK EN transaction CREO LA COMPAÑIA PARA QUE NO FALLE AL INSERTAR LA NUEVA TRANSACCION.

DELETE FROM company       -- BORRO EL REGISTRO PORQUE NO ES EL ID CORRECTO
WHERE id = 'CcU-9999';

INSERT INTO company (id) VALUES ('b-9999'); -- company_id ES FK EN transaction CREO LA COMPAÑIA PARA QUE NO FALLE AL INSERTAR LA NUEVA TRANSACCION.

SELECT * FROM company
WHERE id = 'b-9999';

-- MODIFICAR NOT NULL EN iban, pin, cvv, expiring_date que puse al crear la tabla.

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(34) NULL;

ALTER TABLE credit_card
MODIFY COLUMN pin CHAR(4) NULL;

ALTER TABLE credit_card
MODIFY COLUMN cvv CHAR(3) NULL;

ALTER TABLE credit_card
MODIFY COLUMN expiring_date VARCHAR(10) NULL;

INSERT INTO credit_card (id) VALUES ('CcU-9999');   -- CREO EL ID 'CcU-9999' EN LA TABLA credit_card.

SELECT * FROM credit_card
WHERE id = 'CcU-9999';

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999','b-9999', 9999, 829.999, -117.999, NOW() ,111.11, 0);  -- ASUMO NOW() COMO NO ME DAN EL VALOR ESPECIFICO.

SELECT * FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- 4-) Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

ALTER TABLE credit_card
DROP COLUMN pan;

DESCRIBE credit_card;

-- NIVEL 2

-- 1-) Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT * FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- 2-) Será necesaria que crees una vista llamada VistaMarketing.

CREATE VIEW v_VistaMarketing AS
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount), 2) AS media_compras FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name, c.phone, c.country;

SELECT * FROM v_VistaMarketing
ORDER BY media_compras DESC;

SELECT company_id, ROUND(AVG(amount), 2) AS media_compras FROM transaction -- --- SUBQUERY
WHERE declined = 0
GROUP BY company_id
ORDER BY media_compras DESC;

-- 3-) Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT company_name, phone, country FROM v_VistaMarketing
WHERE country = 'Germany';

ALTER TABLE credit_card  -- ADICIONAR EL CAMPO ELIMINADO PARA PODER MOSTRAR EL MODELO ERP DE LA PREGUNTA 1 DEL NIVEL 1.
ADD  pan VARCHAR(16);

ALTER TABLE credit_card -- BORRAR CAMPO pan CREADO
DROP COLUMN pan;

-- NIVEL 3

-- 1-) Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama...

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

-- --------------------- TABLA data_user -------------------------------------------
  
RENAME TABLE user TO data_user;    -- MODIFICAR EL NOMBRE QUE ME DAN POR EL QUE DEBE SALIR EN EL MODELO

ALTER TABLE data_user DROP PRIMARY KEY;  -- ELIMINA LA CONDICION DE CLAVE PRIMARIA
ALTER TABLE data_user MODIFY id INT NOT NULL;  -- SE MODIFICA id  INT
ALTER TABLE data_user ADD PRIMARY KEY(id);    -- RECUPERA UNICIDAD PK

ALTER TABLE data_user                          -- CAMBIAR EL NOMBRE DEL CAMPO
RENAME COLUMN email TO personal_email;

DESCRIBE data_user;    -- VERIFICAR CAMBIOS

-- --------------------- TABLA transaction -------------------------------------------
SELECT user_id         -- PARA VERIFICAR CUAL ES EL ELEMENTO QUE NO ESTA EN LA TABLA data_user y me provoca error al tratar de crear la FK.
FROM transaction
WHERE user_id NOT IN (SELECT id FROM data_user);

DELETE FROM transaction       -- ELIMINO LA TRANSACCION HUERFANA Y USO EL LIMIT 1 POR SEGURIDAD.
WHERE user_id = 9999
LIMIT 1;

ALTER TABLE transaction  -- CREO RELACION ENTRE transaction Y data_user
ADD CONSTRAINT fk_transaction
FOREIGN KEY(user_id) REFERENCES data_user(id);

DESCRIBE transaction; 

-- --------------------- TABLA company -------------------------------------------

ALTER TABLE company  -- ELIMINAR CAMPO website
DROP COLUMN website;

-- --------------------- TABLA credit_card -------------------------------------------

ALTER TABLE credit_card 
MODIFY id VARCHAR(20) PRIMARY KEY NOT NULL;

ALTER TABLE credit_card 
MODIFY iban VARCHAR(50);

ALTER TABLE credit_card 
MODIFY pin VARCHAR(4);

ALTER TABLE credit_card 
MODIFY cvv INT;

ALTER TABLE credit_card 
MODIFY expiring_date VARCHAR(20);


ALTER TABLE credit_card
ADD fecha_actual DATE;

DESCRIBE credit_card;

-- 2-) La empresa también le pide crear una vista llamada "InformeTecnico".

CREATE VIEW v_InformeTecnico AS
SELECT t.id AS transaction_id, t.amount, t.timestamp, d.name AS user_name, d.surname AS user_surname, cc.iban AS card_iban, c.company_name FROM transaction t
JOIN data_user d ON t.user_id = d.id
JOIN credit_card cc ON t.credit_card_id = cc.id
JOIN company c ON t.company_id = c.id;

SELECT * FROM v_InformeTecnico
ORDER BY transaction_id DESC;