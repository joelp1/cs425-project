CREATE TABLE Customer(
   customerID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   firstName		VARCHAR(20),
   middleName		VARCHAR(20),
   lastName			VARCHAR(20),
   birthDate		DATE,
   emailAddress  	VARCHAR(30),
   password       	VARCHAR(25) NOT NULL,
   tombstone      	BOOLEAN
);

CREATE TABLE Account(
   customerID		INT PRIMARY KEY,
   maxCredit      	INT,
   balance    		INT,
   mpr              NUMERIC(2,2),
   FOREIGN KEY (customerID) REFERENCES Customer(customerID),
   CONSTRAINT goodBalance CHECK (balance < maxCredit)
);

CREATE TABLE Phone(
   phoneNumber		NUMERIC(12) PRIMARY KEY,
   phoneType		VARCHAR(10),
   customerID		INT,
   FOREIGN KEY (customerID) REFERENCES Customer(customerID)
);

CREATE TABLE Shipper(
   shipperID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   companyName		VARCHAR(25),
   phoneNumber		NUMERIC(12)
);
         
CREATE TABLE Address(
   addressID	INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   country		VARCHAR(15),
   aState		VARCHAR(8),
   city			VARCHAR(15),
   zipCode		VARCHAR(8),
   street		VARCHAR(30),
   aNumber		VARCHAR(8),
   unit			VARCHAR(4),
   shipperID	INT,
   FOREIGN KEY (shipperID) REFERENCES Shipper(shipperID)
);


CREATE TABLE Store(
   storeID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   storeType	VARCHAR(20),
   storeName	VARCHAR(25),
   taxRate		NUMERIC(2,2),
   addressID	INT,
   FOREIGN KEY (addressID) REFERENCES Address(addressID)
); 

CREATE TABLE Warehouse(
   warehouseID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   warehouseName	VARCHAR(25),
   phoneNumber		NUMERIC(12),
   storeID     INT,
   addressID   INT,
   FOREIGN KEY (addressID) REFERENCES Address(addressID),
   FOREIGN KEY (storeID) REFERENCES Store(storeID)
);

CREATE TABLE Customer_Address(
   customerID	INT,
   addressID	INT,
   PRIMARY KEY (customerID, addressID),
   FOREIGN KEY (customerID) REFERENCES Customer(customerID),
   FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE TABLE Customer_Order(
   orderID			INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   quantity			INT,
   trackingNumber	NUMERIC(22),
   orderDate		DATE,
   shipDate			DATE,
   sources          VARCHAR(150),
   customerID		INT,
   shipperID		INT,
   addressID        INT,
   FOREIGN KEY (customerID) REFERENCES Customer(customerID),
   FOREIGN KEY (shipperID) REFERENCES Shipper(shipperID),
   FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE TABLE Order_Feedback(
   orderID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   orderDate	DATE,
   rating		NUMERIC(1),
   comments		LONG,
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE
);


CREATE TABLE Customer_Return(
   returnAuthorDate		DATE,
   orderID				INT NOT NULL AUTO_INCREMENT,
   returnTracking		NUMERIC(22), 
   comments				LONG,
   refundAmount			NUMERIC(10,2),
   PRIMARY KEY (returnAuthorDate, orderID),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE
);

CREATE TABLE Bill(
   billingAcctNumber	INT,
   bill_ID				INT,
   amountDue			NUMERIC(10,2),
   dueDate				DATE,
   PRIMARY KEY (billingAcctNumber, bill_ID)
);

CREATE TABLE Payment(
   orderID				INT,
   pTimeStamp			TIMESTAMP,
   paymentType			VARCHAR(10),
   amountPaid			NUMERIC(10,2),
   cardNumber			NUMERIC(16),
   cardHolderName		VARCHAR(30),
   company				VARCHAR(25),
   expirationDate		DATE,
   securityCode			NUMERIC(3),
   billingAcctNumber	INT,
   bill_ID				INT,
   PRIMARY KEY (orderID, pTimeStamp),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE,
   FOREIGN KEY (billingAcctNumber, bill_ID) REFERENCES Bill(billingAcctNumber, bill_ID),
   CONSTRAINT bill_payment UNIQUE (billingAcctNumber, bill_ID)
);

CREATE TABLE Bundle(
   bundleID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   description	LONG
);

CREATE TABLE Category(
   categoryID		INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   categoryName		VARCHAR(15),
   description		LONG
);

CREATE TABLE Manufacturer(
   manufacturerID	INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   name				VARCHAR(25),
   phoneNumber		NUMERIC(12),
   country			VARCHAR(15)
);

CREATE TABLE Stock(
   stockID				INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   quantityAvailable	NUMERIC(10),
   warehouseID			INT,
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
); 

CREATE TABLE Product(
   productID			VARCHAR(15),
   SKU					VARCHAR(20),
   name					VARCHAR(100),
   description			LONG,
   releaseDate			DATE,
   MSRP					NUMERIC(10,2),
   pSize				VARCHAR(30),
   weight				VARCHAR(14),
   color				VARCHAR(10),
   quantityPerUnit		NUMERIC(8),
   warrantyLength		VARCHAR(10),
   discontinued			NUMERIC(1),
   stockID				INT,
   categoryID			INT,
   manufacturerID		INT,
   PRIMARY KEY (productID, SKU),
   FOREIGN KEY (categoryID) REFERENCES Category(categoryID),
   FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID),
   FOREIGN KEY (stockID) REFERENCES Stock(stockID),
   CONSTRAINT sID UNIQUE (stockID)
);

CREATE TABLE Review(
   reviewID		VARCHAR(20) PRIMARY KEY,
   rating		NUMERIC(1),
   reviewText	LONG,
   reviewDate	DATE,
   productID	VARCHAR(15),
   SKU			VARCHAR(20),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU)
);



CREATE TABLE Restock_Order(
   restockOrderID	INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   quantity			NUMERIC(10),
   status			VARCHAR(100),
   amountPaid		NUMERIC(10,2),
   warehouseID		INT,
   manufacturerID	INT,
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
   FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)
);

CREATE TABLE Product_Bundle(
   productID	VARCHAR(15),
   SKU			VARCHAR(20),
   bundleID		INT,
   PRIMARY KEY (productID, SKU, bundleID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (bundleID) REFERENCES Bundle(bundleID)
);

CREATE TABLE Product_Restock(
   productID		VARCHAR(15),
   SKU				VARCHAR(20),
   restockOrderID	INT,
   PRIMARY KEY (productID, SKU, restockOrderID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (restockOrderID) REFERENCES Restock_Order(restockOrderID)
);

CREATE TABLE Product_Order(
   productID	VARCHAR(15),
   SKU			VARCHAR(20),
   orderID		INT,
   PRIMARY KEY (productID, orderID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID)
);

CREATE TABLE Store_Product(
   storeID			INT,
   productID		VARCHAR(15),
   SKU				VARCHAR(20),
   sellingPrice		NUMERIC(10,2),
   PRIMARY KEY (storeID, productID, SKU)
);          

INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES(NULL, NULL, NULL, NULL, NULL, 'unknown', NULL);
INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES('Carrie', 'M', 'Clarkson', '2017-04-17', 'cclarkson@gmail.com', 'ponta123', NULL);
INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES('Eddie', 'K', 'Bright', '1976-05-14', 'ebright@gmail.com', 'effect1910', NULL);
INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES('Anne', 'G', 'Jefferson', '1988-12-10', 'ajefferson@gmail.com', 'p44ck4', NULL);
INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES('Xavier', 'C', 'Coulson', '1974-06-14', 'xcoulson@gmail.com', 'tm5dqb', NULL);
INSERT INTO Customer(firstName, middleName, lastName, birthDate, emailAddress, password, tombstone) VALUES('Devan', 'J', 'Osborn', '1995-08-24', 'dosborn@gmail.com', '6f9u0z', NULL);

INSERT INTO Account VALUES(2, 200, 50, NULL);
INSERT INTO Account VALUES(3, 200, 50, NULL);
INSERT INTO Account VALUES(4, 200, 0, NULL);
INSERT INTO Account VALUES(5, 200, 0, NULL);
INSERT INTO Account VALUES(6, 200, 0, NULL);

INSERT INTO Phone VALUES(4778555465, 'Home', 2);
INSERT INTO Phone VALUES(2275191699, 'Cell', 3);
INSERT INTO Phone VALUES(6703616928, 'Home', 4);
INSERT INTO Phone VALUES(6124568473, 'Home', 4);
INSERT INTO Phone VALUES(8592802741, 'Home', 5);
INSERT INTO Phone VALUES(3816166086, 'Home', 6);

INSERT INTO Shipper(companyName, phoneNumber) VALUES('USPS', 805229085);
INSERT INTO Shipper(companyName, phoneNumber)  VALUES('UPS', 8007425877);
INSERT INTO Shipper(companyName, phoneNumber)  VALUES('Fedex', 800463339);

INSERT INTO Address VALUES(2, 'USA', 'AL', 'Alabaster', 35007, 'West Nicolls St.', 7418, 6, 1);
INSERT INTO Address VALUES(3, 'USA', 'GA', 'Smyrna', 30080, 'North High Ave.', 55, NULL, 2);
INSERT INTO Address VALUES(4, 'USA', 'MI', 'Allen Park', 48101, 'Jennings Ave.', 45, NULL, 3);

INSERT INTO Address VALUES(5, 'USA', 'SC', 'Waukesha', 29576, 'Cherry Ave.', 7073, NULL, NULL);
INSERT INTO Address VALUES(6, 'USA', 'MA', 'Billerica', 01821, 'Blackburn St.', 190, NULL, NULL);
INSERT INTO Address VALUES(7, 'USA', 'PA', 'Allison Park', 15101, 'Railroad St.',94, NULL, NULL);
INSERT INTO Address VALUES(8, 'USA', 'GA', 'Dublin', 31021, 'East Clay St.', 906, NULL, NULL);

INSERT INTO Address VALUES(9, 'USA', 'TN', 'Tullahoma', 37388, 'La Sierra Lane', 8, NULL, NULL);
INSERT INTO Address VALUES(10, 'USA', 'NJ', 'Little Falls', 07424, 'S. Birchpond St.', 190, NULL, NULL);
INSERT INTO Address VALUES(11, 'USA', 'FL', 'Lilburn', 30047, 'Aspen St.', 256, NULL, NULL);
INSERT INTO Address VALUES(12, 'USA', 'AZ', 'Glendale', 85302, 'East Race St.', 845, NULL, NULL);
INSERT INTO Address VALUES(13, 'USA', 'NY', 'Hamburg', 14075, 'Garfield Lane', 547, NULL, NULL);


INSERT INTO Store VALUES(1, 'Online', 'Best Buy', 0.11, NULL);

INSERT INTO Warehouse VALUES(1, 'Hughes', 4569964518, 1, 5);
INSERT INTO Warehouse VALUES(2, 'Hozzby', 2193709020, NULL, 6);
INSERT INTO Warehouse VALUES(3, 'Monte', 5642132722, NULL, 7);
INSERT INTO Warehouse VALUES(4, 'WDirect', 8863587190, NULL, 8);

INSERT INTO Customer_Address VALUES(2, 9);
INSERT INTO Customer_Address VALUES(3, 10);
INSERT INTO Customer_Address VALUES(4, 11);
INSERT INTO Customer_Address VALUES(5, 12);
INSERT INTO Customer_Address VALUES(6, 13);

INSERT INTO Manufacturer VALUES(1, 'Sony', 7732024561, 'Japan');
INSERT INTO Manufacturer VALUES(2, 'Apple', 5638776504, 'China');
INSERT INTO Manufacturer VALUES(3, 'Hewlett-Packard', 9205648311, 'China');
INSERT INTO Manufacturer VALUES(4, 'Intel', 3152919229, 'USA');
INSERT INTO Manufacturer VALUES(5, 'TSMC', 3279041512, 'China');

INSERT INTO Stock VALUES(1, 354, 1);
INSERT INTO Stock VALUES(2, 4568, 1);
INSERT INTO Stock VALUES(3, 435, 2);
INSERT INTO Stock VALUES(4, 8574, 3);
INSERT INTO Stock VALUES(5, 12358, 4);

INSERT INTO Category VALUES(1, 'Headphones', NULL);
INSERT INTO Category VALUES(2, 'Computers', NULL);
INSERT INTO Category VALUES(3, 'Printers/Ink', NULL);
INSERT INTO Category VALUES(4, 'Computer Parts', NULL);

INSERT INTO Product VALUES('A98DB973', 'B07TD96LY2', 'Sony WF-1000XM3 Noise Cancelling Earbuds', 'Freedom perfected in a truly wireless design with industry leading noise canceling powered by Sony’s proprietary HD Noise Canceling Processor QN1e. Form meets function with up to 24 total hours of battery life with quick charging touchpad controls premium sound quality and smart features like Wearing Detection and Quick Attention Mode.', '2019-07-01', 250.00, '5.7x4.7x2.5in', '3.53 ounces', 'Black', 1, '2 Years', 0, 2, 1, 1);
INSERT INTO Product VALUES('30S70U3A', 'B07HB4QHC3', 'HP Deskjet 2622', 'Easy mobile printing: Start printing and get connected quickly with easy setup from your smartphone, tablet, or PC. Connect your smartphone or tablet directly to your printer?and easily print without accessing a network. Manage printing tasks and scan on the go with the free HP All-in-One Printer Remote mobile app. Affordable at-home printing: Full of value?print up to twice as many pages with Original HP high-yield ink cartridges. Get high-quality prints?time after time?with an all-in-one designed and built to be reliable. Everything you need?right away: Take charge of your tasks and finish in less time with the easy-to-use 2. 2-inch (5. 5 cm) display. Quickly copy, scan, and fax multipage documents with the 35-page automatic document feeder. Access coloring pages, recipes, coupons, and more with free HP Printables?delivered on your schedule. Designed to fit your life: Save your space with a compact all-in-one designed to fit on your desk, on a shelf, or anywhere you need it. Print in any room you choose?without causing disruptions. Optional quiet mode helps keep noise to a minimum. COMPATIBLE OPERATING SYSTEMS - Windows 10, Windows 8.1, Windows 8, Windows 7; OS X v10.8 Mountain Lion, OS X v10.9 Mavericks, OS X v10.10 Yosemite.', '2015-08-14', 39.89, '14.33x17.72x8.54in', '12.37 lbs', 'White', 1, '1 Year', 0, 3, 3, 3);
INSERT INTO Product VALUES('MZDQMF17', 'B07211W6X2', 'MacBook Air', 'The most loved Mac is about to make you fall in love all over again. Available in silver, space gray, and gold, the new thinner and lighter MacBook Air features a brilliant Retina display with True Tone technology, Touch ID, the latest-generation keyboard, and a Force Touch trackpad. The iconic wedge is created from 100 percent recycled aluminum, making it the greenest Mac ever.1 And with all-day battery life, MacBook Air is your perfectly portable, do-it-all notebook.', '2018-12-14', 999.00, '0.68x12.8x8.94in', '2.96 lbs', 'Space Grey', 1, '1 Year', 0, 1, 2, 2);
INSERT INTO Product VALUES('T4793KVQ', 'B07598VZR8', 'Intel Core i7-8700K', 'Outstanding gaming experiences extend beyond personal gameplay to your entire gaming community. Share those experiences by live-streaming or recording, editing, and posting your epic highlights.', '2017-10-05', 373.99, '4x2x4.6in', '2.88 ounces', NULL, 1, '1 Year', 0, 4, 4, 4);
INSERT INTO Product VALUES('0A1RAQP8','B07STGGQ18', 'AMD Ryzen 5 3600', 'AMD CPProductU 100 100000031box Ryzen 5 3600 6C 12T 4200MHz 36MB 65W AM4 Wraith Stealth', '2019-07-01',  185.99, '1.57x1.57x0.24in', '1.6 ounces', NULL, 1, '2 Years', 0, 5, 4, 5);

INSERT INTO Store_Product VALUES(1, 'T4793KVQ', 'B07598VZR8', 325.25);
INSERT INTO Store_Product VALUES(1, 'MZDQMF17 ', 'B07211W6X2', 855.25);
INSERT INTO Store_Product VALUES(1, '0A1RAQP8','B07STGGQ18', 150.75);
INSERT INTO Store_Product VALUES(1, '30S70U3A', 'B07HB4QHC3', 35.45);
INSERT INTO Store_Product VALUES(1, 'A98DB973', 'B07TD96LY2', 225.00);

INSERT INTO Bundle VALUES(1, 'Laptop and Printer');

INSERT INTO Product_Bundle VALUES('MZDQMF17 ', 'B07211W6X2', 1);
INSERT INTO Product_Bundle VALUES('30S70U3A', 'B07HB4QHC3', 1);

INSERT INTO Customer_Order VALUES(1, 1, 09243418643242106562, '2019-08-19', '2019-08-20', NULL, 2, 1, 9); 
INSERT INTO Customer_Order VALUES(2, 1, 09243414597242106562, '2019-12-10', NULL, NULL, 3, 1, 10);
INSERT INTO Customer_Order VALUES(3, 1, 04326698363223743408, '2019-04-02', '2019-04-03', NULL, 4, 2, 11);
INSERT INTO Customer_Order VALUES(4, 1, 47859678643242106562, '2019-09-10', NULL, NULL, 5, 2, 12);
INSERT INTO Customer_Order VALUES(5, 1, 09243418643242147989, '2019-11-27', NULL, NULL, 5, 3, 13);

INSERT INTO Bill VALUES(1, 1, 325.50, '2019-05-01');

INSERT INTO Payment VALUES(1, '2019-08-20 09:06:41', 'Debit', 949.33, 4335036354372213, 'Carrie Clarkson', 'VISA', '2022-12-01', 475, 1, 1); 
INSERT INTO Payment VALUES(2, '2019-12-10 12:58:51', 'Debit', 325.50, 4612561184122698, 'Eddie Bright', 'VISA', '2024-06-01', 383,  NULL, NULL); 
INSERT INTO Payment VALUES(3, '2019-09-10 15:48:11', 'Credit', 39.33, 4591266383845199, 'Xavier Coulson', 'VISA', '2020-08-01', 873, NULL, NULL);
INSERT INTO Payment VALUES(4, '2019-11-27 03:25:18', 'Credit', 183.14, 4028748688403660, 'Devan Osborn', 'VISA', '2026-11-01', 114, NULL, NULL); 
INSERT INTO Payment VALUES(5, '2019-07-01 18:33:48', 'Debit', 39.35, 4028748688403660, 'Devan Osborn', 'VISA', '2026-11-01', 114, NULL, NULL);

INSERT INTO Product_Order VALUES('MZDQMF17 ', 'B07211W6X2', 1);
INSERT INTO Product_Order VALUES('T4793KVQ', 'B07598VZR8', 2);
INSERT INTO Product_Order VALUES('A98DB973', 'B07TD96LY2', 3);
INSERT INTO Product_Order VALUES('30S70U3A', 'B07HB4QHC3', 4);
INSERT INTO Product_Order VALUES('0A1RAQP8','B07STGGQ18', 5);

INSERT INTO Order_Feedback VALUES(1,'2019-08-19',  1, 'Awful customer service.');
INSERT INTO Order_Feedback VALUES(2,'2019-04-02',  5,  'A+++ seller. Shipped the item sooner than expected');

INSERT INTO Review VALUES(4564, 1, 'Charged me $700 to fix my laptop under warranty', '2019-08-25', 'MZDQMF17', 'B07211W6X2');

INSERT INTO Restock_Order VALUES(1, 1500, 'Waiting for shipment', 281250, 1, 1);

INSERT INTO Product_Restock VALUES('A98DB973', 'B07TD96LY2', 1);

/* Function that modifies the stock of a user specified product*/
DELIMITER $$
CREATE PROCEDURE reduceStock(
   IN product VARCHAR(15),
   IN quantity INT, 
   OUT warehouse_mapping VARCHAR(150))
BEGIN
   DECLARE stock INT;
   DECLARE available INT DEFAULT 0;
   DECLARE warehouse VARCHAR(15);
   DECLARE leftOver INT DEFAULT 0;
   SET warehouse_mapping = '';
   
   SELECT stockID
   INTO stock
   FROM Product
   WHERE productID = product;
   
   test_loop: LOOP
      IF (quantity = 0) THEN
         LEAVE test_loop;
      END IF;
      
      SELECT warehouseID, quantityAvailable
      INTO warehouse, available
      FROM Stock
      WHERE stockID = stock
      HAVING quantityAvailable = MAX(quantityAvailable);
      
      IF (available >= quantity) THEN
         SET leftOver = available - quantity;
         UPDATE Stock
         SET quantityAvailable = leftOver
         WHERE warehouseID = warehouse
         AND stockID = stock;
         SET warehouse_mapping = CONCAT(warehouse, ':', quantity, ',', warehouse_mapping);
         LEAVE test_loop;
      END IF;
      IF (available < quantity) THEN
         SET leftOver = 0;
         SET quantity = quantity - available;
         UPDATE Stock
         SET quantityAvailable = leftOver
         WHERE warehouseID = warehouse
         AND stockID = stock;
         SET warehouse_mapping = CONCAT(warehouse, ':', available, ',', warehouse_mapping);
      END IF;
   END LOOP;
END$$
