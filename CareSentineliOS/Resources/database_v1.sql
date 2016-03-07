
CREATE TABLE devices(
id INTEGER PRIMARY KEY,
name varchar(255) NOT NULL,
hw_id varchar(255),
hw_name varchar(255) NOT NULL,
type INTEGER,
uuid varchar(255) NOT NULL,
ignored BOOL,
created_at INTEGER
);

CREATE TABLE properties(
id INTEGER PRIMARY KEY,
name varchar(255),
device_type INTEGER,
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

CREATE TABLE contacts(
id INTEGER PRIMARY KEY,
name varchar(255),
number varchar(255)
);

INSERT INTO properties(name,device_type,units) VALUES("Bed Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Chair Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Toilet Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Incontinence Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Call Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Portal Sensor",1,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Fall Button",2,NULL);