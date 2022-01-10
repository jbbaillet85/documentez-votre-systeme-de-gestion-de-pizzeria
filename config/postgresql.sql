CREATE DATABASE ocpizza;


CREATE USER ocpizzauser WITH PASSWORD 'ocPizza!';


ALTER ROLE ocpizzauser
SET client_encoding TO 'utf8';


ALTER ROLE ocpizzauser
SET default_transaction_isolation TO 'read committed';


ALTER ROLE ocpizzauser
SET timezone TO 'UTC';

GRANT ALL PRIVILEGES ON DATABASE ocpizza TO ocpizzauser;

