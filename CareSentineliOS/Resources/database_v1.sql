CREATE TABLE sites(
id INTEGER PRIMARY KEY,
site_id varchar(255) UNIQUE NOT NULL
);

CREATE TABLE customers(
id INTEGER PRIMARY KEY,
customer_id varchar(255) UNIQUE NOT NULL
);


CREATE TABLE devices(
id INTEGER PRIMARY KEY,
name varchar(255) NOT NULL,
hw_id varchar(255),
hw_name varchar(255) NOT NULL,
uuid varchar(255) NOT NULL,
site_id integer NOT NULL,
customer_id integer,
user_id integer,
ignored BOOL,
created_at INTEGER
);

CREATE TABLE users(
id INTEGER PRIMARY KEY,
email varchar(255) NOT NULL,
password varchar(255) NOT NULL,
created_at INTEGER
);


CREATE TABLE user_sites(
site_id INTEGER NOT NULL,
user_id INTEGER NOT NULL
);

CREATE TABLE user_customers(
customer_id INTEGER NOT NULL,
user_id INTEGER NOT NULL
);


CREATE TABLE properties(
id INTEGER PRIMARY KEY,
name varchar(255),
units varchar(255)
);

CREATE TABLE devices_properties_values(
id INTEGER PRIMARY KEY,
device_id INTEGER NOT NULL,
property_id INTEGER NOT NULL,
value varchar(255) NOT NULL,
created_at INTEGER NOT NULL,
dismissed_at INTEGER
);

CREATE TABLE  devices_enabled_properties(
id INTEGER PRIMARY KEY,
device_id INTEGER NOT NULL,
property_id INTEGER NOT NULL,
enabled BOOL,
delay INTEGER
);

INSERT INTO properties(name,units) VALUES("Bed Sensor",NULL);
INSERT INTO properties(name,units) VALUES("Chair Sensor",NULL);
INSERT INTO properties(name,units) VALUES("Toilet Sensor",NULL);
INSERT INTO properties(name,units) VALUES("Incontinence Sensor",NULL);
INSERT INTO properties(name,units) VALUES("Call Sensor",NULL);
INSERT INTO properties(name,units) VALUES("Portal Sensor",NULL);