USE itmt430;

CREATE TABLE IF NOT EXISTS accounts 
(
id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
name varchar(50) NOT NULL,
email varchar(100) NOT NULL,
phone varchar(20),
country varchar(50),
address varchar(100),
city varchar(50),
state varchar(50),
zipcode varchar(10),
occupation varchar(50)
);