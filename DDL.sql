CREATE TABLE Customer(
   customerID	INT AUTO_INCREMENT PRIMARY KEY,
   firstName	VARCHAR(20),
   middleName	VARCHAR(20),
   lastName		VARCHAR(20),
   birthDate	DATE,
   emailAddress  VARCHAR(30),
   password       VARCHAR(25) NOT NULL,
   tombstone      BOOLEAN
);

CREATE TABLE Account(
   customerID		INT PRIMARY KEY,
   maxCredit      	INT,
   balance    		INT,
   mpr              NUMERIC(2,2),
   FOREIGN KEY (customerID) REFERENCES Customer(customerID)
);

CREATE TABLE Phone(
   phoneNumber		NUMERIC(12) PRIMARY KEY,
   phoneType		VARCHAR(10),
   customerID		INT,
   FOREIGN KEY (customerID) REFERENCES Customer(customerID)
);

CREATE TABLE Warehouse(
   warehouseID		VARCHAR(15) PRIMARY KEY,
   warehouseName	VARCHAR(25),
   phoneNumber		NUMERIC(12)
);

CREATE TABLE Shipper(
   shipperID		VARCHAR(20) PRIMARY KEY,
   companyName		VARCHAR(25),
   phoneNumber		NUMERIC(12)
);

CREATE TABLE Store(
   storeID		VARCHAR(20) PRIMARY KEY,
   storeType	VARCHAR(8),
   taxRate		NUMERIC(2,2),
   warehouseID	VARCHAR(15),
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);          

CREATE TABLE Address(
   addressID	VARCHAR(10) PRIMARY KEY,
   country		VARCHAR(15),
   aState		VARCHAR(8),
   city			VARCHAR(15),
   zipCode		VARCHAR(8),
   street		VARCHAR(30),
   aNumber		VARCHAR(8),
   unit			VARCHAR(4),
   shipperID	VARCHAR(20),
   storeID		VARCHAR(20),
   warehouseID  VARCHAR(15),
   FOREIGN KEY (shipperID) REFERENCES Shipper(shipperID),
   FOREIGN KEY (storeID) REFERENCES Store(storeID),
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
   CONSTRAINT aSID UNIQUE (storeID),
   CONSTRAINT wID UNIQUE (warehouseID)
);

CREATE TABLE Customer_Address(
   customerID	INT,
   addressID	VARCHAR(10),
   PRIMARY KEY (customerID, addressID),
   FOREIGN KEY (customerID) REFERENCES Customer(customerID),
   FOREIGN KEY (addressID) REFERENCES Address(addressID)
);

CREATE TABLE Customer_Order(
   orderID			VARCHAR(15) PRIMARY KEY,
   orderType		VARCHAR(10),
   trackingNumber	NUMERIC(22),
   orderDate		DATE,
   shipDate			DATE,
   customerID		INT,
   shipperID		VARCHAR(20),
   FOREIGN KEY (customerID) REFERENCES Customer(customerID),
   FOREIGN KEY (shipperID) REFERENCES Shipper(shipperID)
);

CREATE TABLE Order_Feedback(
   orderID		VARCHAR(15) PRIMARY KEY,
   orderDate	DATE,
   rating		NUMERIC(1),
   comments		LONG,
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE
);



CREATE TABLE Customer_Return(
   returnAuthorDate		DATE,
   orderID				VARCHAR(15),
   returnTracking		NUMERIC(22), 
   comments				LONG,
   refundAmount			NUMERIC(10,2),
   PRIMARY KEY (returnAuthorDate, orderID),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE
);

CREATE TABLE Bill(
   billingAcctNumber	VARCHAR(15),
   bill_ID				VARCHAR(10),
   amountDue			NUMERIC(10,2),
   dueDate				DATE,
   PRIMARY KEY (billingAcctNumber, bill_ID)
);

CREATE TABLE Payment(
   orderID				VARCHAR(15),
   pTimeStamp			TIMESTAMP,
   paymentType			VARCHAR(10),
   amountPaid			NUMERIC(10,2),
   cardNumber			NUMERIC(16),
   cardHolderName		VARCHAR(30),
   company				VARCHAR(25),
   expirationDate		DATE,
   securityCode			NUMERIC(3),
   availableCredit		NUMERIC(10,2),
   billingAcctNumber	VARCHAR(15),
   bill_ID				VARCHAR(10),
   PRIMARY KEY (orderID, pTimeStamp),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID) ON DELETE CASCADE,
   FOREIGN KEY (billingAcctNumber, bill_ID) REFERENCES Bill(billingAcctNumber, bill_ID),
   CONSTRAINT bill_payment UNIQUE (billingAcctNumber, bill_ID)
);

CREATE TABLE Bundle(
   bundleID		VARCHAR(20) PRIMARY KEY,
   description	LONG
);

CREATE TABLE Category(
   categoryID		VARCHAR(20) PRIMARY KEY,
   categoryName		VARCHAR(15),
   description		LONG
);

CREATE TABLE Manufacturer(
   manufacturerID	VARCHAR(15) PRIMARY KEY,
   name				VARCHAR(25),
   phoneNumber		NUMERIC(12),
   country			VARCHAR(15)
);

CREATE TABLE Stock(
   stockID				VARCHAR(15) PRIMARY KEY,
   quantitySold			NUMERIC(10),
   quantityAvailable	NUMERIC(10)
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
   stockID				VARCHAR(15),
   categoryID			VARCHAR(20),
   manufacturerID		VARCHAR(15),
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
   restockOrderID	VARCHAR(15) PRIMARY KEY,
   quantity			NUMERIC(10),
   status			VARCHAR(100),
   amountPaid		NUMERIC(10,2),
   warehouseID		VARCHAR(15),
   manufacturerID	VARCHAR(15),
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID),
   FOREIGN KEY (manufacturerID) REFERENCES Manufacturer(manufacturerID)
);

CREATE TABLE Product_Bundle(
   productID	VARCHAR(15),
   SKU			VARCHAR(20),
   bundleID		VARCHAR(20),
   PRIMARY KEY (productID, SKU, bundleID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (bundleID) REFERENCES Bundle(bundleID)
);

CREATE TABLE Product_Restock(
   productID		VARCHAR(15),
   SKU				VARCHAR(20),
   restockOrderID	VARCHAR(15),
   PRIMARY KEY (productID, SKU, restockOrderID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (restockOrderID) REFERENCES Restock_Order(restockOrderID)
);

CREATE TABLE Product_Order(
   productID	VARCHAR(15),
   SKU			VARCHAR(20),
   orderID		VARCHAR(15),
   PRIMARY KEY (productID, orderID),
   FOREIGN KEY (productID, SKU) REFERENCES Product(productID, SKU),
   FOREIGN KEY (orderID) REFERENCES Customer_Order(orderID)
);

CREATE TABLE Store_Product(
   storeID			VARCHAR(20),
   productID		VARCHAR(15),
   SKU				VARCHAR(20),
   sellingPrice		NUMERIC(10,2),
   PRIMARY KEY (storeID, productID, SKU)
);          


CREATE TABLE Warehouse_Stock(
   stockID			VARCHAR(15),
   warehouseID		VARCHAR(15),
   PRIMARY KEY (stockID, warehouseID),
   FOREIGN KEY (stockID) REFERENCES Stock(stockID),
   FOREIGN KEY (warehouseID) REFERENCES Warehouse(warehouseID)
);

INSERT INTO Customer VALUES(NULL, NULL, NULL, NULL, 'unknown', NULL);
INSERT INTO Customer VALUES('Carrie', 'M', 'Clarkson', '2017-04-17', 'cclarkson@gmail.com', 'ponta123');
INSERT INTO Customer VALUES('Eddie', 'K', 'Bright', '1976-05-14', 'ebright@gmail.com', 'effect1910');
INSERT INTO Customer VALUES('Anne', 'G', 'Jefferson', '1988-12-10', 'ajefferson@gmail.com', 'p44ck4');
INSERT INTO Customer VALUES('Xavier', 'C', 'Coulson', '1974-06-14', 'xcoulson@gmail.com', 'tm5dqb');
INSERT INTO Customer VALUES('Devan', 'J', 'Osborn', '1995-08-24', 'dosborn@gmail.com', '6f9u0z');

INSERT INTO Account VALUES(0, 0, 0);
INSERT INTO Account VALUES(1, 1000, 0);
INSERT INTO Account VALUES(2, 1000, 100);
INSERT INTO Account VALUES(3, 1000, 1000);
INSERT INTO Account VALUES(4, 1000, 900);
INSERT INTO Account VALUES(5, 0, 0);


INSERT INTO Phone VALUES(4778555465, 'Home', 1);
INSERT INTO Phone VALUES(2275191699, 'Cell', 1);
INSERT INTO Phone VALUES(6703616928, 'Home', 2);
INSERT INTO Phone VALUES(6124568473, 'Home', 3);
INSERT INTO Phone VALUES(8592802741, 'Home', 4);
INSERT INTO Phone VALUES(3816166086, 'Home', 5);

INSERT INTO Shipper VALUES(1456786, 'USPS', 805229085);
INSERT INTO Shipper VALUES(1243243, 'UPS', 8007425877);
INSERT INTO Shipper VALUES(1234568, 'Fedex', 800463339);

INSERT INTO Warehouse VALUES(568978, 'Hughes', 4569964518);
INSERT INTO Warehouse VALUES(789456, 'Hozzby', 2193709020);
INSERT INTO Warehouse VALUES(289791, 'Monte', 5642132722);
INSERT INTO Warehouse VALUES(894891, 'WDirect', 8863587190);

INSERT INTO Store VALUES(7894, 'Online', 0.11, 568978);
INSERT INTO Store VALUES(9653, 'Retail', 0.05, 289791);
INSERT INTO Store VALUES(1256, 'Retail', 0.18, 894891);
INSERT INTO Store VALUES(3977, 'Online', 0.07, 789456);

INSERT INTO Address VALUES(789489, 'USA', 'NY', 'Richmond Hill', 11418, 'Middle River Lane', 7495, NULL, 1456786, NULL, NULL);
INSERT INTO Address VALUES(865456, 'USA', 'AL', 'Alabaster', 35007, 'West Nicolls St.', 7418, 6, 1243243, NULL, NULL);
INSERT INTO Address VALUES(568462, 'USA', 'GA', 'Smyrna', 30080, 'North High Ave.', 55, NULL, 1234568, NULL, NULL);

INSERT INTO Address VALUES(789789, 'USA', 'MI', 'Allen Park', 48101, 'Jennings Ave.', 45, NULL, NULL, 7894 ,NULL);
INSERT INTO Address VALUES(562987, 'USA', 'SC', 'Waukesha', 29576, 'Cherry Ave.', 7073, NULL, NULL, 9653 ,NULL);
INSERT INTO Address VALUES(549762, 'USA', 'MA', 'Billerica', 01821, 'Blackburn St.', 190, NULL, NULL, 1256 ,NULL);
INSERT INTO Address VALUES(123478, 'USA', 'PA', 'Allison Park', 15101, 'Railroad St.',94, NULL, NULL, 3977 ,NULL);

INSERT INTO Address VALUES(582145, 'USA', 'GA', 'Dublin', 31021, 'East Clay St.', 906, NULL, NULL, NULL,568978);
INSERT INTO Address VALUES(849841, 'USA', 'TN', 'Tullahoma', 37388, 'La Sierra Lane', 8, NULL, NULL, NULL, 789456);
INSERT INTO Address VALUES(265893, 'USA', 'NJ', 'Little Falls', 07424, 'S. Birchpond St.', 190, NULL, NULL, NULL, 894891);
INSERT INTO Address VALUES(354711, 'USA', 'FL', 'Lilburn', 30047, 'Aspen St.', 256, NULL, NULL, NULL, 289791);

INSERT INTO Address VALUES(789454, 'USA', 'AZ', 'Glendale', 85302, 'East Race St.', 845, NULL, NULL, NULL,NULL);
INSERT INTO Address VALUES(457248, 'USA', 'NY', 'Hamburg', 14075, 'Garfield Lane', 547, NULL, NULL, NULL, NULL);
INSERT INTO Address VALUES(698554, 'USA', 'IL', 'Palatine', 60067, 'Rockledge St.', 283, NULL, NULL, NULL, NULL);
INSERT INTO Address VALUES(555784, 'USA', 'FL', 'Palm Coast', 32137, 'Center St.', 391, NULL, NULL, NULL, NULL);
INSERT INTO Address VALUES(222471, 'USA', 'IN', 'Portage', 46368, 'Academy Drive', 210, NULL, NULL, NULL, NULL);

INSERT INTO Customer_Address VALUES(1, 789454);
INSERT INTO Customer_Address VALUES(2, 457248);
INSERT INTO Customer_Address VALUES(3, 698554);
INSERT INTO Customer_Address VALUES(4, 555784);
INSERT INTO Customer_Address VALUES(5, 222471);

INSERT INTO Manufacturer VALUES(45785, 'Sony', 7732024561, 'Japan');
INSERT INTO Manufacturer VALUES(87845, 'Apple', 5638776504, 'China');
INSERT INTO Manufacturer VALUES(45671, 'Hewlett-Packard', 9205648311, 'China');
INSERT INTO Manufacturer VALUES(25836, 'Intel', 3152919229, 'USA');
INSERT INTO Manufacturer VALUES(90782, 'TSMC', 3279041512, 'China');

INSERT INTO Stock VALUES(7894, 354, 78);
INSERT INTO Stock VALUES(9773, 4568, 857);
INSERT INTO Stock VALUES(2471, 435, 654);
INSERT INTO Stock VALUES(8025, 8574, 1235);
INSERT INTO Stock VALUES(1567, 12358, 2574);


INSERT INTO Warehouse_Stock VALUES(7894, 568978);
INSERT INTO Warehouse_Stock VALUES(9773, 789456);
INSERT INTO Warehouse_Stock VALUES(2471, 568978);
INSERT INTO Warehouse_Stock VALUES(8025, 289791);
INSERT INTO Warehouse_Stock VALUES(1567, 894891);

INSERT INTO Category VALUES(45679, 'Headphones', NULL);
INSERT INTO Category VALUES(78941, 'Computers', NULL);
INSERT INTO Category VALUES(22894, 'Printers/Ink', NULL);
INSERT INTO Category VALUES(67458, 'Computer Parts', NULL);

INSERT INTO Product VALUES('A98DB973', 'B07TD96LY2', 'Sony WF-1000XM3 Noise Cancelling Earbuds', 'Freedom perfected in a truly wireless design with industry leading noise canceling powered by Sony’s proprietary HD Noise Canceling Processor QN1e. Form meets function with up to 24 total hours of battery life with quick charging touchpad controls premium sound quality and smart features like Wearing Detection and Quick Attention Mode.', '2019-07-01', 250.00, '5.7x4.7x2.5in', '3.53 ounces', 'Black', 1, '2 Years', 0, 7894, 45679, 45785);
INSERT INTO Product VALUES('30S70U3A', 'B07HB4QHC3', 'HP Deskjet 2622', 'Easy mobile printing: Start printing and get connected quickly with easy setup from your smartphone, tablet, or PC. Connect your smartphone or tablet directly to your printer?and easily print without accessing a network. Manage printing tasks and scan on the go with the free HP All-in-One Printer Remote mobile app. Affordable at-home printing: Full of value?print up to twice as many pages with Original HP high-yield ink cartridges. Get high-quality prints?time after time?with an all-in-one designed and built to be reliable. Everything you need?right away: Take charge of your tasks and finish in less time with the easy-to-use 2. 2-inch (5. 5 cm) display. Quickly copy, scan, and fax multipage documents with the 35-page automatic document feeder. Access coloring pages, recipes, coupons, and more with free HP Printables?delivered on your schedule. Designed to fit your life: Save your space with a compact all-in-one designed to fit on your desk, on a shelf, or anywhere you need it. Print in any room you choose?without causing disruptions. Optional quiet mode helps keep noise to a minimum. COMPATIBLE OPERATING SYSTEMS - Windows 10, Windows 8.1, Windows 8, Windows 7; OS X v10.8 Mountain Lion, OS X v10.9 Mavericks, OS X v10.10 Yosemite.', '2015-08-14', 39.89, '14.33x17.72x8.54in', '12.37 lbs', 'White', 1, '1 Year', 0, 9773, 22894, 45671);
INSERT INTO Product VALUES('MZDQMF17 ', 'B07211W6X2', 'MacBook Air', 'The most loved Mac is about to make you fall in love all over again. Available in silver, space gray, and gold, the new thinner and lighter MacBook Air features a brilliant Retina display with True Tone technology, Touch ID, the latest-generation keyboard, and a Force Touch trackpad. The iconic wedge is created from 100 percent recycled aluminum, making it the greenest Mac ever.1 And with all-day battery life, MacBook Air is your perfectly portable, do-it-all notebook.', '2018-12-14', 999.00, '0.68x12.8x8.94in', '2.96 lbs', 'Space Grey', 1, '1 Year', 0, 2471, 78941, 87845);
INSERT INTO Product VALUES('T4793KVQ', 'B07598VZR8', 'Intel Core i7-8700K', 'Outstanding gaming experiences extend beyond personal gameplay to your entire gaming community. Share those experiences by live-streaming or recording, editing, and posting your epic highlights.', '2017-10-05', 373.99, '4x2x4.6in', '2.88 ounces', NULL, 1, '1 Year', 0, 8025, 67458, 25836);
INSERT INTO Product VALUES('0A1RAQP8','B07STGGQ18', 'AMD Ryzen 5 3600', 'AMD CPU 100 100000031box Ryzen 5 3600 6C 12T 4200MHz 36MB 65W AM4 Wraith Stealth', '2019-07-01',  185.99, '1.57x1.57x0.24in', '1.6 ounces', NULL, 1, '2 Years', 0, 1567, 67458, 90782);

INSERT INTO Store_Product VALUES(7894, 'T4793KVQ', 'B07598VZR8', 325.25);
INSERT INTO Store_Product VALUES(7894, 'MZDQMF17 ', 'B07211W6X2', 855.25);
INSERT INTO Store_Product VALUES(7894, '0A1RAQP8','B07STGGQ18', 150.75);
INSERT INTO Store_Product VALUES(7894, '30S70U3A', 'B07HB4QHC3', 35.45);
INSERT INTO Store_Product VALUES(7894, 'A98DB973', 'B07TD96LY2', 225.00);
INSERT INTO Store_Product VALUES(9653, 'T4793KVQ', 'B07598VZR8', 310.00);
INSERT INTO Store_Product VALUES(9653, 'MZDQMF17 ', 'B07211W6X2', 825.00);
INSERT INTO Store_Product VALUES(9653, '0A1RAQP8','B07STGGQ18', 140.25);
INSERT INTO Store_Product VALUES(1256, 'T4793KVQ', 'B07598VZR8', 315.25);
INSERT INTO Store_Product VALUES(1256, 'MZDQMF17 ', 'B07211W6X2', 800.00);
INSERT INTO Store_Product VALUES(1256, '0A1RAQP8','B07STGGQ18', 155.20);
INSERT INTO Store_Product VALUES(1256, '30S70U3A', 'B07HB4QHC3', 33.33);
INSERT INTO Store_Product VALUES(1256, 'A98DB973', 'B07TD96LY2', 200.00);
INSERT INTO Store_Product VALUES(3977, '0A1RAQP8','B07STGGQ18', 25.68);
INSERT INTO Store_Product VALUES(3977, 'A98DB973', 'B07TD96LY2', 157.45);

INSERT INTO Bundle VALUES(456789, 'Laptop and Printer ');

INSERT INTO Product_Bundle VALUES('MZDQMF17 ', 'B07211W6X2', 456789);
INSERT INTO Product_Bundle VALUES('30S70U3A', 'B07HB4QHC3', 456789);

INSERT INTO Customer_Order VALUES(2597792, 'Online', 09243418643242106562, '2019-08-19', '2019-08-20', 1, 1456786); 
INSERT INTO Customer_Order VALUES(8749848, 'Retail', NULL, '2019-12-10', NULL, 2, NULL);
INSERT INTO Customer_Order VALUES(1793824, 'Online', 04326698363223743408
, '2019-04-02', '2019-04-03', 3, 1234568);
INSERT INTO Customer_Order VALUES(2589741, 'Retail', NULL, '2019-09-10', NULL, 4, NULL);
INSERT INTO Customer_Order VALUES(3336841, 'Retail', NULL, '2019-11-27', NULL, 4, NULL);
INSERT INTO Customer_Order VALUES(5847951, 'Online', 04326698363223743408, '2019-07-01', '2019-07-01', 5, 1243243);

INSERT INTO Bill VALUES(189475, 458967, 325.50, '2019-05-01');

INSERT INTO Payment VALUES(2597792, '2019-08-20 09:06:41', 'Debit', 949.33, 4335036354372213, 'Carrie Clarkson', 'VISA', '2022-12-01', 475, 0.00, NULL, NULL); 
INSERT INTO Payment VALUES(8749848, '2019-12-10 12:58:51', 'Debit', 325.50, 4612561184122698, 'Eddie Bright', 'VISA', '2024-06-01', 383, 0.00, NULL, NULL); 
INSERT INTO Payment VALUES(2589741, '2019-09-10 15:48:11', 'Credit', 39.33, 4591266383845199, 'Xavier Coulson', 'VISA', '2020-08-01', 873, 0.00, NULL, NULL);
INSERT INTO Payment VALUES(3336841, '2019-11-27 03:25:18', 'Credit', 183.14, 4028748688403660, 'Devan Osborn', 'VISA', '2026-11-01', 114, 0.00, NULL, NULL); 
INSERT INTO Payment VALUES(5847951, '2019-07-01 18:33:48', 'Debit', 39.35, 4028748688403660, 'Devan Osborn', 'VISA', '2026-11-01', 114, 0.00, NULL, NULL);

INSERT INTO Product_Order VALUES('MZDQMF17 ', 'B07211W6X2', 2597792);
INSERT INTO Product_Order VALUES('T4793KVQ', 'B07598VZR8', 8749848);
INSERT INTO Product_Order VALUES('A98DB973', 'B07TD96LY2', 1793824);
INSERT INTO Product_Order VALUES('30S70U3A', 'B07HB4QHC3', 2589741);
INSERT INTO Product_Order VALUES('0A1RAQP8','B07STGGQ18', 3336841);
INSERT INTO Product_Order VALUES('30S70U3A', 'B07HB4QHC3', 5847951);

INSERT INTO Order_Feedback VALUES(2597792,'2019-08-19',  1, 'Awful customer service.');
INSERT INTO Order_Feedback VALUES(1793824,'2019-04-02',  5,  'A+++ seller. Shipped the item sooner than expected');

INSERT INTO Review VALUES(4564, 1, 'Charged me $700 to fix my laptop under warranty', '2019-08-25', 'MZDQMF17 ', 'B07211W6X2');

INSERT INTO Restock_Order VALUES(48786, 1500, 'Waiting for shipment', 281250, 568978, 45785);

INSERT INTO Product_Restock VALUES('A98DB973', 'B07TD96LY2', 48786);
