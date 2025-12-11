UPDATE performance_schema.setup_actors
SET ENABLED = 'NO', HISTORY = 'NO'
WHERE HOST = '%' AND USER = '%';

INSERT INTO performance_schema.setup_actors
(HOST,USER,ROLE,ENABLED,HISTORY)
VALUES('localhost','root','%','YES','YES');

UPDATE performance_schema.setup_instruments
SET ENABLED = 'YES', TIMED = 'YES';

UPDATE performance_schema.setup_consumers
SET ENABLED = 'YES';
