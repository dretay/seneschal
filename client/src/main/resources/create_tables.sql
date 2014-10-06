DROP TABLE IF EXISTS readings;
DROP TABLE IF EXISTS sensors;
DROP TABLE IF EXISTS sensortypes;
DROP TABLE IF EXISTS nodes;

CREATE TABLE sensortypes (
     id            SERIAL PRIMARY KEY,
     shortname     text NOT NULL,
     longname      text NOT NULL
);
insert into sensortypes(id,shortname,longname) values(0,'S_DOOR','Door and window');
insert into sensortypes(id,shortname,longname) values(1,'S_MOTION','Motion');
insert into sensortypes(id,shortname,longname) values(2,'S_SMOKE','Smoke');
insert into sensortypes(id,shortname,longname) values(3,'S_LIGHT', 'Light Actuator (on/off)');
insert into sensortypes(id,shortname,longname) values(4,'S_DIMMER', 'Dimmable device');
insert into sensortypes(id,shortname,longname) values(5,'S_COVER', 'Window covers or shades');
insert into sensortypes(id,shortname,longname) values(6,'S_TEMP', 'Temperature');
insert into sensortypes(id,shortname,longname) values(7,'S_HUM', 'Humidity');
insert into sensortypes(id,shortname,longname) values(8,'S_BARO', 'Barometer');
insert into sensortypes(id,shortname,longname) values(9,'S_WIND', 'Wind');
insert into sensortypes(id,shortname,longname) values(10,'S_RAIN', 'Rain');
insert into sensortypes(id,shortname,longname) values(11,'S_UV', 'UV');
insert into sensortypes(id,shortname,longname) values(12,'S_WEIGHT', 'Weight');
insert into sensortypes(id,shortname,longname) values(13,'S_POWER', 'Power measuring device');
insert into sensortypes(id,shortname,longname) values(14,'S_HEATER', 'Heater device');
insert into sensortypes(id,shortname,longname) values(15,'S_DISTANCE', 'Distance');
insert into sensortypes(id,shortname,longname) values(16,'S_LIGHT_LEVEL', 'Light') ;
insert into sensortypes(id,shortname,longname) values(17,'S_ARDUINO_NODE', 'Arduino node');
insert into sensortypes(id,shortname,longname) values(18,'S_ARDUINO_RELAY', 'Arduino repeating node');
insert into sensortypes(id,shortname,longname) values(19,'S_LOCK', 'Lock');
insert into sensortypes(id,shortname,longname) values(20,'S_IR', 'Ir sender/receiver');
insert into sensortypes(id,shortname,longname) values(21,'S_WATER','Water');
insert into sensortypes(id,shortname,longname) values(22,'S_AIR_QUALITY','Air quality');
insert into sensortypes(id,shortname,longname) values(23,'S_CUSTOM','Custom');
insert into sensortypes(id,shortname,longname) values(24,'S_DUST','Dust level');
insert into sensortypes(id,shortname,longname) values(25,'S_SCENE_CONTROLLER','Scene controller');

CREATE TABLE nodes (
     id            SERIAL PRIMARY KEY,
     protocol      TEXT,
     sketchName    TEXT,
     sketchVersion TEXT,
     created       TIMESTAMP DEFAULT current_timestamp
);
CREATE TABLE sensors (
     id            SERIAL PRIMARY KEY,
     node	         INT NOT NULL REFERENCES nodes (id),
     sensortype    INT NOT NULL REFERENCES sensortypes (id),
     sensorindex   INT NOT NULL,
     created       TIMESTAMP DEFAULT current_timestamp,
     CONSTRAINT node_sensors_fk FOREIGN KEY (node) REFERENCES nodes(id) ON DELETE CASCADE,
     UNIQUE (node,sensorindex)
);

CREATE TABLE readings (
     id            SERIAL PRIMARY KEY,
     node	         INT NOT NULL REFERENCES nodes (id),
     sensorindex   INT NOT NULL,
     real_value	   REAL,
     created       TIMESTAMP DEFAULT current_timestamp,
     CONSTRAINT node_readings_fk FOREIGN KEY (node) REFERENCES nodes(id) ON DELETE CASCADE
);
CREATE INDEX readings_created_idx on readings using btree(created);