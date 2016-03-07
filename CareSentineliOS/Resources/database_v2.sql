
CREATE TABLE devices(
id INTEGER PRIMARY KEY,
name varchar(255) NOT NULL,
hw_id varchar(255),
type INTEGER,
uuid varchar(255) NOT NULL,
ignored BOOL,
created_at INTEGER
);

CREATE TABLE properties(
id INTEGER PRIMARY KEY,
device_type INTEGER,
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

INSERT INTO properties(name,device_type,units) VALUES("Bed Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Chair Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Toilet Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Incontinence Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Call Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Portal Sensor",0,NULL);
INSERT INTO properties(name,device_type,units) VALUES("Fall Button",1,NULL);

CREATE TABLE contacts(
id INTEGER PRIMARY KEY,
name varchar(255),
number varchar(255)
);
