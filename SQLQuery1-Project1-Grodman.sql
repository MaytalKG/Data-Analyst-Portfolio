-- PROJECT 1

USE master

GO

IF EXISTS (SELECT * FROM sysdatabases WHERE name='Proj1-Grodman')
			DROP DATABASE "Proj1-Grodman"

GO

CREATE DATABASE "Proj1-Grodman"

GO

USE "Proj1-Grodman"

/*
Expenses Payable – 
Refers to expenses a company owes to suppliers for goods or services received but has not yet paid.
Expenses that relate to a specific accounting period but not yet paid or invoiced. 
These are recorded as a credit (liability) account in the accounting system
as they reflect amounts the business still owes for the current accounting period.
*/

GO

/*
Each Supplier supplies many Products.
Each Supplier supplies different Products.
Each Supplier receives many Supllier Orders.
*/

CREATE TABLE Suppliers
(SupplierID INT IDENTITY,
CompanyName VARCHAR(40) NOT NULL,
ContactEmail VARCHAR(50),
Country VARCHAR(10),
Phone VARCHAR(20),
CONSTRAINT sup_supid_pk PRIMARY KEY (SupplierID),
CONSTRAINT sup_email_ck CHECK (ContactEmail LIKE '%@%.%'),
CONSTRAINT sup_phone_uk UNIQUE (Phone))

GO

/*
Each Product is linked to a Supplier.
*/

CREATE TABLE Products
(ProductID VARCHAR(6),
ProductName VARCHAR(40) NOT NULL,
UnitPrice MONEY NOT NULL,
SupplierID INT,
CONSTRAINT prod_prodid_pk PRIMARY KEY (ProductID),
CONSTRAINT prod_prodid_ck CHECK (ProductID LIKE '__-%'),
CONSTRAINT prod_sup_fk FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID))

GO

/*
Each Supplier Order is linked to a Supplier.
Each Supplier Order has at least One Supplier Invoice.
*/

CREATE TABLE SupplierOrders
(SupOrderID VARCHAR(10),
SupOrderDate Date,
SupplierID INT,
OrderTotal Money NOT NULL,
CONSTRAINT supor_suporid_pk PRIMARY KEY (SupOrderID),
CONSTRAINT supor_suporid_ck CHECK (SupOrderID LIKE '__-____'),
CONSTRAINT supor_supid_fk FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID))

GO

/*
Each Supplier Invoice contains at least One Invoice Item.
Each Supplier Invoice is linked to a Supplier order.
A Supplier Invoice can be issued for a single payment or multiple payments.
Each Supplier Invoice includes payment terms (such as the Due Date) 
and shows the current payment Status.
*/

CREATE TABLE SupplierInvoices
(SupInvoiceID INT IDENTITY(25000,1),
SupInvoiceDate DATE, 
SupOrderID VARCHAR(10),
DueDate DATE,
InvTotal MONEY NOT NULL,
PaymentNumber VARCHAR(6),
"Status" VARCHAR(10) NOT NULL, 
CONSTRAINT supin_supinid_pk PRIMARY KEY (SupInvoiceID),
CONSTRAINT supin_suporid_fk FOREIGN KEY (SupOrderID) REFERENCES SupplierOrders (SupOrderID),
CONSTRAINT supin_suporid_ck CHECK (SupOrderID LIKE '__-____'),
CONSTRAINT supin_paynum_ck CHECK (PaymentNumber LIKE '_/_'),
CONSTRAINT supin_status_ck CHECK("Status" IN ('Paid','Unpaid')))

GO

/*
Each Invoice Item is linked to a Product & a Supplier Invoice.
*/

CREATE TABLE Items
(ItemID INT,
SupInvoiceID INT,
ProductID VARCHAR(6),
UnitPrice MONEY NOT NULL,
Quantity INT,
Discount FLOAT,
CONSTRAINT itm_itmid_pk PRIMARY KEY (ItemID),
CONSTRAINT itm_supin_fk FOREIGN KEY (SupInvoiceID) REFERENCES SupplierInvoices (SupInvoiceID),
CONSTRAINT itm_prodit_fk FOREIGN KEY (ProductID) REFERENCES Products (ProductID),
CONSTRAINT itm_disc_ck CHECK (Discount >= 0 and Discount <= 1))

GO

INSERT INTO Suppliers (CompanyName, ContactEmail, Country, Phone)
VALUES  ('HOODIES','service@hoodies.co.il','ISRAEL','972-3-5419764'),
		('NIKE','myniketeam@nike.com','USA','1-800-8066453'),
		('FOX HOME','wecare@foxhome.co.il','ISRAEL','972-3-7133000'),
		('SEPHORA','hr-my@sephora.my','FRANCE','33-1-46-177000')

GO

-- All UnitPrice values are in NIS (New Israeli Shekel)

INSERT INTO Products (ProductID, ProductName, UnitPrice, SupplierID)
VALUES	('HO-1','Sofia Dress',119.9,1),
		('HO-2','Mindy Shorts',89.9,1),
		('HO-3','Magic Pants',149.9,1),
		('HO-4','Yana Shirt',79.9,1),
		('HO-5','X Top',49.9,1),
		('NK-1','Nike Flex Runner 3',159.9,2),
		('NK-2','Nike Dunk Low',419.9,2),
		('NK-3','Nike Field General',329.9,2),
		('NK-4','Nike LD-1000',429.9,2),
		('NK-5','Nike Air Max 90',629.9,2),
		('NK-6','Air Jordan 1 Low',549.9,2),
		('NK-7','Nike Pegasus 41',599.9,2),
		('FH-1','Tablecloth Tara',299.9,3),
		('FH-2','Bath Towel Diva',109.9,3),
		('FH-3','Cooking Pot Elementi',649.9,3),
		('FH-4','Cooking Pot Materia',519.9,3),
		('FH-5','Frying Pan Materia',429.9,3),
		('FH-6','Main Plate Glory',54.9,3),
		('SP-1','Valentino - Donna Born In Roma',504.9,4),
		('SP-2','Chanel - CHANCE EAU TENDRE',633.6,4),
		('SP-3','Burberry - Burberry Goddess',126.4,4),
		('SP-4','Burberry - Mini Her & Goddess',388.8,4)

GO

INSERT INTO SupplierOrders (SupOrderID, SupOrderDate, SupplierID, OrderTotal)
VALUES  ('HO-0001','20241205',1,1510.39),
		('NK-0002','20241205',2,1767.03),
		('FH-0003','20241214',3,6806.15),
		('NK-0004','20241216',2,7808.26),
		('SP-0005','20241217',4,6635.14),
		('HO-0006','20241220',1,1950.97),
		('FH-0007','20241225',3,4676.62),
		('SP-0008','20241229',4,3828.30),
		('NK-0009','20241231',2,8642.38),
		('FH-0010','20241231',3,5207.24),
		('HO-0011','20250102',1,2493.12),
		('NK-0012','20250103',2,4462.98)

GO

INSERT INTO SupplierInvoices (SupInvoiceDate,SupOrderID,DueDate,InvTotal,PaymentNumber,"Status")
VALUES 	('20250110','HO-0001','20250331',489.44,'1/3','paid'),
		('20250111','NK-0002','20250331',566.91,'1/2','paid'),
		('20250111','FH-0003','20250331',1142.24,'1/5','paid'),
		('20250114','NK-0004',NULL,1547.64,'1/3','paid'),
		('20250116','SP-0005','20250331',1807.77,'1/4','paid'),
		('20250121','HO-0006','20250331',1090.74,'1/2','paid'),
		('20250125','FH-0007','20250331',703.36,'1/3','paid'),
		('20250128','SP-0008','20250331',3828.30,'1/1','paid'),
		('20250128','HO-0001','20250331',489.44,'2/3','unpaid'),
		('20250131','NK-0004',NULL,3747.09,'2/3','paid'),
		('20250201','FH-0003','20250430',1327.57,'2/5','paid'),
		('20250204','NK-0009','20250430',2991.41,'1/3','unpaid'),
		('20250206','NK-0002','20250430',1200.12,'2/2','paid'),
		('20250207','SP-0005','20250430',1990.85,'2/4','paid'),
		('20250210','FH-0010','20250430',2342.52,'1/2','paid'),
		('20250215','HO-0011','20250430',895.04,'1/3','paid'),
		('20250217','FH-0003','20250430',1593.66,'3/5','paid'),
		('20250222','HO-0006','20250430',860.23,'2/2','unpaid'),
		('20250225','NK-0009','20250430',2677.08,'2/3','unpaid'),
		('20250226','HO-0011','20250430',1342.40,'2/3','unpaid'),
		('20250228','NK-0004',NULL,2513.53,'3/3','paid'),
		('20250228','FH-0003','20250430',1054.08,'4/5','unpaid'),
		('20250301','SP-0005','20250531',2280.96,'3/4','unpaid'),
		('20250304','HO-0001','20250531',531.51,'3/3','unpaid'),
		('20250304','FH-0010','20250531',2864.72,'2/2','paid'),
		('20250305','FH-0007','20250531',2924.54,'2/3','paid'),
		('20250309','FH-0003','20250531',1688.60,'5/5','unpaid'),
		('20250310','SP-0005','20250531',555.57,'4/4','paid'),
		('20250312','NK-0009','20250531',2973.90,'3/3','unpaid'),
		('20250315','NK-0012','20250531',4462.98,'1/1','unpaid'),
		('20250317','FH-0007','20250531',1048.73,'3/3','paid'),
		('20250322','HO-0011','20250531',255.68,'3/3','unpaid')

GO

INSERT INTO Items(ItemID, SupInvoiceId, ProductID, UnitPrice, Quantity, Discount)
VALUES	(250001,25000,'HO-2',89.9,2,0.3),
		(250002,25000,'HO-4',79.9,5,0.3),
		(250003,25000,'HO-1',119.9,1,0.3),
		(250011,25001,'NK-5',629.9,1,0.1),
		(250021,25002,'FH-2',109.9,4,0.2),
		(250022,25002,'FH-6',54.9,18,0.2),
		(250031,25003,'NK-4',429.9,4,0.1),
		(250041,25004,'SP-3',126.4,3,0),
		(250042,25004,'SP-1',504.9,2,0.15),
		(250043,25004,'SP-2',633.6,1,0.1),
		(250051,25005,'HO-5',49.9,6,0.3),
		(250052,25005,'HO-2',89.9,2,0.3),
		(250053,25005,'HO-4',79.9,6,0.3),
		(250054,25005,'HO-3',149.9,4,0.3),
		(250061,25006,'FH-2',109.9,8,0.2),
		(250071,25007,'SP-3',126.4,6,0),
		(250072,25007,'SP-4',388.8,4,0),
		(250073,25007,'SP-1',504.9,3,0),
		(250081,25008,'HO-5',49.9,5,0.3),
		(250082,25008,'HO-3',149.9,3,0.3),
		(250091,25009,'NK-2',419.9,2,0.15),
		(250092,25009,'NK-3',329.9,5,0),
		(250093,25009,'NK-6',549.9,2,0.2),
		(250094,25009,'NK-5',629.9,1,0.2),
		(250101,25010,'FH-1',299.9,2,0.25),
		(250102,25010,'FH-3',649.9,1,0.4),
		(250103,25010,'FH-4',519.9,1,0.4),
		(250104,25010,'FH-2',109.9,2,0.2),
		(250111,25011,'NK-4',429.9,4,0.15),
		(250112,25011,'NK-7',599.9,3,0.15),
		(250121,25012,'NK-1',159.9,2,0),
		(250122,25012,'NK-3',329.9,1,0.15),
		(250123,25012,'NK-7',599.9,1,0),
		(250131,25013,'SP-2',633.6,1,0.1),
		(250132,25013,'SP-4',388.8,3,0.15),
		(250133,25013,'SP-1',504.9,1,0.15),
		(250141,25014,'FH-4',519.9,1,0.1),
		(250142,25014,'FH-5',429.9,3,0),
		(250143,25014,'FH-3',649.9,1,0.1),
		(250151,25015,'HO-1',119.9,4,0.2),
		(250152,25015,'HO-4',79.9,8,0.2),
		(250161,25016,'FH-5',429.9,4,0.3),
		(250162,25016,'FH-3',649.9,1,0.4),
		(250171,25017,'HO-3',149.9,2,0.3),
		(250172,25017,'HO-1',119.9,4,0.3),
		(250173,25017,'HO-2',89.9,5,0.3),
		(250181,25018,'NK-5',629.9,5,0.15),
		(250191,25019,'HO-2',89.9,3,0.2),
		(250192,25019,'HO-4',79.9,5,0.2),
		(250193,25019,'HO-3',149.9,2,0.2),
		(250194,25019,'HO-1',119.9,3,0.2),
		(250195,25019,'HO-5',49.9,7,0.2),
		(250201,25020,'NK-7',599.9,3,0),
		(250202,25020,'NK-2',419.9,2,0.15),
		(250211,25021,'FH-6',54.9,24,0.20),
		(250221,25022,'SP-2',633.6,4,0.1),
		(250231,25023,'HO-4',79.9,2,0.3),
		(250232,25023,'HO-1',119.9,3,0.3),
		(250233,25023,'HO-2',89.9,1,0.3),
		(250234,25023,'HO-3',149.9,1,0.3),
		(250241,25024,'FH-2',109.9,4,0),
		(250242,25024,'FH-1',299.9,5,0.3),
		(250243,25024,'FH-3',649.9,1,0.1),
		(250244,25024,'FH-6',54.9,18,0.2),
		(250251,25025,'FH-1',299.9,4,0.25),
		(250252,25025,'FH-5',429.9,1,0.25),
		(250253,25025,'FH-6',54.9,12,0),
		(250254,25025,'FH-4',519.9,2,0.25),
		(250255,25025,'FH-2',109.9,3,0.2),
		(250261,25026,'FH-1',299.9,3,0.25),
		(250262,25026,'FH-3',649.9,1,0.4),
		(250263,25026,'FH-4',519.9,2,0.4),
		(250271,25027,'SP-3',126.4,1,0),
		(250272,25027,'SP-1',504.9,1,0.15),
		(250281,25028,'NK-6',549.9,1,0.15),
		(250282,25028,'NK-3',329.9,3,0.15),
		(250283,25028,'NK-1',159.9,7,0.15),
		(250284,25028,'NK-2',419.9,2,0.15),
		(250291,25029,'NK-5',629.9,2,0.25),
		(250292,25029,'NK-3',329.9,7,0.1),
		(250293,25029,'NK-7',599.9,4,0.4),
		(250301,25030,'FH-6',54.9,12,0),
		(250302,25030,'FH-4',519.9,1,0.25),
		(250311,25031,'HO-4',79.9,4,0.2)

GO

SELECT *
FROM Suppliers s

GO

SELECT *, FORMAT(p.UnitPrice,'c','en-il') AS "UnitPrice in NIS"
FROM Products p
ORDER BY p.SupplierID

GO

SELECT *, FORMAT(so.OrderTotal,'c','en-il') AS "OrderTotal in NIS"
FROM SupplierOrders so
ORDER BY so.SupOrderDate

GO

SELECT *, FORMAT(si.InvTotal,'c','en-il') AS "InvTotal in NIS"
FROM SupplierInvoices si

GO

SELECT *, FORMAT(it.UnitPrice,'c','en-il') AS "UnitPrice in NIS"
FROM Items it

GO

SELECT si.SupOrderID, FORMAT(SUM(si.InvTotal),'c','en-il') AS "SUM Invoice per Order", 
FORMAT(so.OrderTotal,'c','en-il') AS "OrderTotal"
FROM SupplierInvoices si JOIN SupplierOrders so
ON si.SupOrderID=so.SupOrderID
GROUP BY si.SupOrderID, so.OrderTotal

GO

SELECT it.SupInvoiceID, Format(SUM(it.UnitPrice*it.Quantity*(1-it.Discount)),'c','en-il') AS "SUM Items per Invoice", 
FORMAT(si.InvTotal,'c','en-il') AS "InvTotal"
FROM SupplierInvoices si JOIN Items it
ON si.SupInvoiceID=it.SupInvoiceID
GROUP BY it.SupInvoiceID, si.InvTotal

GO



