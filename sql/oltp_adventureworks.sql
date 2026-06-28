CREATE SCHEMA IF NOT EXISTS oltp;

CREATE TABLE oltp.product (
    productid INT PRIMARY KEY,
    name TEXT,
    standardcost NUMERIC,
    listprice NUMERIC,
    modifieddate TIMESTAMP
);

CREATE TABLE oltp.customer (
    customerid INT PRIMARY KEY,
    name TEXT,
    email TEXT,
    modifieddate TIMESTAMP
);

CREATE TABLE oltp.salesorderheader (
    salesorderid INT PRIMARY KEY,
    customerid INT,
    orderdate TIMESTAMP,
    salespersonid INT,
    territoryid INT,
    modifieddate TIMESTAMP
);

CREATE TABLE oltp.salesorderdetail (
    salesorderdetailid INT PRIMARY KEY,
    salesorderid INT,
    productid INT,
    orderqty INT,
    unitprice NUMERIC,
    linetotal NUMERIC,
    modifieddate TIMESTAMP
);

-- DADOS MÍNIMOS (IMPORTANTE PARA TESTE)
INSERT INTO oltp.product VALUES
(1,'Bike',100,150,now()),
(2,'Helmet',50,80,now());

INSERT INTO oltp.customer VALUES
(1,'João','joao@email.com',now()),
(2,'Maria','maria@email.com',now());

INSERT INTO oltp.salesorderheader VALUES
(1,1,now(),1,1,now());

INSERT INTO oltp.salesorderdetail VALUES
(1,1,1,2,150,300,now()),
(2,1,2,1,80,80,now());