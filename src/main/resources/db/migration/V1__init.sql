DROP TABLE IF EXISTS category;
CREATE TABLE category (
   id bigint NOT NULL AUTO_INCREMENT,
   name VARCHAR(400) NOT NULL,
   description VARCHAR(400) NULL,
   createdDate timestamp DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (ID)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
 
INSERT INTO category (name) values ('Restaurant');
INSERT INTO category (name) values ('Food and Drink');
INSERT INTO category (name) values ('Entertainment');
INSERT INTO category (name) values ('Outdoor');
INSERT INTO category (name) values ('Days Out');
INSERT INTO category (name) values ('Life Style');
INSERT INTO category (name) values ('Shopping');
INSERT INTO category (name) values ('Service');
INSERT INTO category (name) values ('Sports and Fitness');
INSERT INTO category (name) values ('Health and Beauty');
