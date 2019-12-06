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
