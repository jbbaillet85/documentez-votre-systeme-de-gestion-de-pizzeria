CREATE DATABASE ocpizza;


CREATE USER OCpizzaUser WITH PASSWORD 'ocPizza!';


ALTER ROLE OCpizzaUser
SET client_encoding TO 'utf8';


ALTER ROLE OCpizzaUser
SET default_transaction_isolation TO 'read committed';


ALTER ROLE OCpizzaUser
SET timezone TO 'UTC';

GRANT ALL PRIVILEGES ON DATABASE ocpizzas TO OCpizzaUser;

