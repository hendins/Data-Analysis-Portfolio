/*

Cleaning Data in PostgreSQL

*/



SELECT * FROM AmazonSales;



--- Change the data type of the orderid column to VARCHAR(30)

ALTER TABLE AmazonSales
ALTER COLUMN orderid TYPE VARCHAR(30);



--- Convert to NUMERIC with a maximum of two decimal places

UPDATE AmazonSales
SET Sales = ROUND(Sales::NUMERIC, 2),
	BuyingCost = ROUND(BuyingCost::NUMERIC, 2),
    Profit = ROUND(Profit::NUMERIC, 2);



--- Change the column name

ALTER TABLE AmazonSales
RENAME COLUMN Segment TO DestinationSegment;



--- Restrict Data in a Column

UPDATE AmazonSales
SET ProductName = 
    CASE 
        WHEN LENGTH(REGEXP_REPLACE(ProductName, '[^\s]', '', 'g')) <= 4 
        THEN ProductName
        ELSE (SPLIT_PART(ProductName, ' ', 1) || ' ' || SPLIT_PART(ProductName, ' ', 2) || ' ' || SPLIT_PART(ProductName, ' ', 3) || ' ' || SPLIT_PART(ProductName, ' ', 4))
    END;



-- Change month format from number to month name

UPDATE AmazonSales
SET OrderDate = TO_CHAR(OrderDate, 'FMMonth DD, YYYY'::text);



--- Remove the OrderID and Country columns from the AmazonSales table

ALTER TABLE AmazonSales
DROP COLUMN OrderID, DROP COLUMN Country;



--- Change the value of the 'ShipMode' column

UPDATE AmazonSales
SET ShipMode = CASE
    WHEN ShipMode = 'First Class' THEN 'Y'
    ELSE 'No'
END;



--- Change each value in a column 

UPDATE AmazonSales
SET Region = LEFT(Region, 1);



--- Add a word after a value in a table

UPDATE AmazonSales
SET Region = Region || ', USA';



--- Discard data with certain conditions

DELETE FROM amazonsales
WHERE Discount = 0.00;

