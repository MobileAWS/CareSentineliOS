INSERT INTO sites(site_id) VALUES('bedroom');

INSERT INTO customers(customer_id) VALUES('7');

INSERT INTO users(email,password,created_at) VALUES('jxmike@gmail.com','password',1436734401);

INSERT INTO user_sites(site_id,user_id) VALUES(1,1);

INSERT INTO user_customers(customer_id,user_id) VALUES(1,1);

INSERT INTO DEVICES(name,hw_id,hw_name,uuid,site_id,customer_id,user_id,ignored,created_at) VALUES('Test Device X','123456789','Sensor Test XYZ','ABCA-9AAA',1,1,1,0,1436734401);

INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,1,1,0);
INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,2,1,0);
INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,3,1,0);
INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,4,1,0);
INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,5,1,0);
INSERT INTO devices_enabled_properties(device_id,property_id,enabled,delay) VALUES(1,6,1,0);

INSERT INTO devices_properties_values(device_id,property_id,value,created_at,dismissed_at) VALUES(1,1,'On',1436734401,1436734401);
INSERT INTO devices_properties_values(device_id,property_id,value,created_at) VALUES(1,2,'Off',1436734401);
INSERT INTO devices_properties_values(device_id,property_id,value,created_at,dismissed_at) VALUES(1,3,'On',1436734401,1436734401);
INSERT INTO devices_properties_values(device_id,property_id,value,created_at,dismissed_at) VALUES(1,4,'On',1436734401,1436734401);
INSERT INTO devices_properties_values(device_id,property_id,value,created_at) VALUES(1,5,'Off',1436734401);
INSERT INTO devices_properties_values(device_id,property_id,value,created_at) VALUES(1,6,'Off',1436734401);

INSERT INTO DEVICES(name,hw_id,hw_name,uuid,site_id,customer_id,user_id,ignored,created_at) VALUES('Ignored Device W','123456780','Sensor Test ZYX','ABCA-9AAA-0000',1,1,1,1,1436734401);