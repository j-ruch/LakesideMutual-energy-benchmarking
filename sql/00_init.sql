DROP DATABASE IF EXISTS customercore;
DROP DATABASE IF EXISTS customermanagement;
DROP DATABASE IF EXISTS customerselfservice;
DROP DATABASE IF EXISTS policymanagement;

CREATE DATABASE customercore;
CREATE DATABASE customermanagement;
CREATE DATABASE customerselfservice;
CREATE DATABASE policymanagement;

GRANT ALL PRIVILEGES ON customercore.* TO 'sa'@'%';
GRANT ALL PRIVILEGES ON customermanagement.* TO 'sa'@'%';
GRANT ALL PRIVILEGES ON customerselfservice.* TO 'sa'@'%';
GRANT ALL PRIVILEGES ON policymanagement.* TO 'sa'@'%';
FLUSH PRIVILEGES;