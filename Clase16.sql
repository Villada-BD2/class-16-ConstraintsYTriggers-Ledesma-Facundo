USE sakila;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employeeNumber INT NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    officeCode VARCHAR(10) NOT NULL,
    reportsTo INT DEFAULT NULL,
    jobTitle VARCHAR(50) NOT NULL,
    PRIMARY KEY (employeeNumber)
);

-- EL 1 Y EL 2 ESTAN DISEÑADOS PARA DAR ERROR Y DARNOS CUENTA QUE ERROR NOS DA

INSERT INTO employees
(employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
VALUES
(1002, 'Murphy', 'Diane', 'x5800', 'dmurphy@classicmodelcars.com', '1', NULL, 'President'),
(1056, 'Patterson', 'Mary', 'x4611', 'mpatterso@classicmodelcars.com', '1', 1002, 'VP Sales'),
(1076, 'Firrelli', 'Jeff', 'x9273', 'jfirrelli@classicmodelcars.com', '1', 1002, 'VP Marketing');


-- 1

INSERT INTO employees
(employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
VALUES
(1100, 'Perez', 'Juan', 'x1234', NULL, '1', 1002, 'Developer');

-- La inserción falla porque la columna email tiene la restricción
-- NOT NULL, por lo que MySQL no permite insertar un valor NULL.


-- 2

UPDATE employees
SET employeeNumber = employeeNumber - 20;

-- La consulta falla porque employeeNumber es PRIMARY KEY.
-- Al restar 20, uno de los nuevos valores puede coincidir con
-- una clave que todavía existe, produciendo una clave duplicada.

UPDATE employees
SET employeeNumber = employeeNumber + 20;

-- En este caso la actualización puede realizarse porque MySQL
-- puede modificar los valores sin generar una colisión entre
-- las claves primarias.


-- 3

ALTER TABLE employees
ADD COLUMN age INT,
ADD CONSTRAINT chk_employee_age
CHECK (age BETWEEN 16 AND 70);


-- 4

SHOW CREATE TABLE film_actor;

-- actor y film tienen una relación muchos a muchos mediante film_actor.
-- film_actor.actor_id referencia a actor.actor_id y
-- film_actor.film_id referencia a film.film_id.
-- Esto garantiza que no pueda existir una relación con un actor
-- o una película inexistente. Además, actor_id y film_id forman
-- una clave primaria compuesta que evita relaciones duplicadas.


-- 5

ALTER TABLE employees
ADD COLUMN lastUpdate DATETIME;

DELIMITER $$

CREATE TRIGGER before_employees_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
END$$

CREATE TRIGGER before_employees_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
END$$

DELIMITER ;


ALTER TABLE employees
ADD COLUMN lastUpdateUser VARCHAR(100);

DROP TRIGGER before_employees_insert;
DROP TRIGGER before_employees_update;

DELIMITER $$

CREATE TRIGGER before_employees_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$

CREATE TRIGGER before_employees_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = CURRENT_USER();
END$$

DELIMITER ;


-- 6

SHOW CREATE TRIGGER sakila.ins_film;
SHOW CREATE TRIGGER sakila.upd_film;
SHOW CREATE TRIGGER sakila.del_film;

-- ins_film:
-- Se ejecuta después de insertar una película en film e inserta
-- su film_id, title y description en film_text.

-- upd_film:
-- Se ejecuta después de actualizar una película. Compara OLD con
-- NEW y actualiza film_text cuando cambia la información correspondiente.

-- del_film:
-- Se ejecuta después de eliminar una película. Utiliza OLD.film_id
-- para eliminar de film_text el registro de esa película.

-- Los tres triggers mantienen film_text sincronizada con film.