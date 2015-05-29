CREATE TABLE devices(
id INTEGER PRIMARY KEY,
name varchar(255) NOT NULL,
site_id integer NOT NULL,
created_at INTEGER
);

CREATE TABLE users(
id INTEGER PRIMARY KEY,
email varchar(255) NOT NULL,
password varchar(255) NOT NULL,
site_id integer NOT NULL,
customer_id INTEGER,
created_at INTEGER
);