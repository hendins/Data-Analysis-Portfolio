/*

Cleaning Data (Procurement PO Quantity & Price Details) in PostgreSQL

*/


--- Delete rows with null values.

DELETE FROM commoditydetail
WHERE
    country IS NULL;
  
	
	
	
	
	
--- Delete column

ALTER TABLE commoditydetail
DROP COLUMN extended_description;

ALTER TABLE commoditydetail
DROP COLUMN unit_of_measure;

ALTER TABLE commoditydetail
DROP COLUMN data_build_date;





--- Rename Columns in Existing Table.

ALTER TABLE commoditydetail
RENAME COLUMN itm_tot_am TO total_amount;

ALTER TABLE commoditydetail
RENAME COLUMN lgl_nm TO legal_name;

ALTER TABLE commoditydetail
RENAME COLUMN Aad_ln_1 TO address_line_1;

ALTER TABLE commoditydetail
RENAME COLUMN ad_ln_2 TO address_line_2;

ALTER TABLE commoditydetail
RENAME COLUMN st TO state;

ALTER TABLE commoditydetail
RENAME COLUMN zip TO zip_code;

ALTER TABLE commoditydetail
RENAME COLUMN ctry TO country;

ALTER TABLE commoditydetail
RENAME COLUMN unit_of_meas_desc TO unit_of_measure;





--- Update Column: Capitalize First Letter of Each Word

UPDATE commoditydetail
SET city = INITCAP(city);

UPDATE commoditydetail
SET commodity_description = INITCAP(commodity_description);

UPDATE commoditydetail
SET commodity_description = REPLACE(commodity_description, 'And', 'and')
WHERE commodity_description ILIKE '%And%';





-- Change column data types

ALTER TABLE commoditydetail
ALTER COLUMN state TYPE VARCHAR(25);

ALTER TABLE commoditydetail
ALTER COLUMN country TYPE VARCHAR(30);





--- Replace column values

UPDATE commoditydetail
SET state = 
  CASE 
    WHEN state = 'AL' THEN 'Alabama'
    WHEN state = 'AK' THEN 'Alaska'
    WHEN state = 'AZ' THEN 'Arizona'
    WHEN state = 'AR' THEN 'Arkansas'
    WHEN state = 'CA' THEN 'California'
    WHEN state = 'CO' THEN 'Colorado'
    WHEN state = 'CT' THEN 'Connecticut'
    WHEN state = 'DE' THEN 'Delaware'
    WHEN state = 'FL' THEN 'Florida'
    WHEN state = 'GA' THEN 'Georgia'
    WHEN state = 'HI' THEN 'Hawaii'
    WHEN state = 'ID' THEN 'Idaho'
    WHEN state = 'IL' THEN 'Illinois'
    WHEN state = 'IN' THEN 'Indiana'
    WHEN state = 'IA' THEN 'Iowa'
    WHEN state = 'KS' THEN 'Kansas'
    WHEN state = 'KY' THEN 'Kentucky'
    WHEN state = 'LA' THEN 'Louisiana'
    WHEN state = 'ME' THEN 'Maine'
    WHEN state = 'MD' THEN 'Maryland'
    WHEN state = 'MA' THEN 'Massachusetts'
    WHEN state = 'MI' THEN 'Michigan'
    WHEN state = 'MN' THEN 'Minnesota'
    WHEN state = 'MS' THEN 'Mississippi'
    WHEN state = 'MO' THEN 'Missouri'
    WHEN state = 'MT' THEN 'Montana'
    WHEN state = 'NE' THEN 'Nebraska'
    WHEN state = 'NV' THEN 'Nevada'
    WHEN state = 'NH' THEN 'New Hampshire'
    WHEN state = 'NJ' THEN 'New Jersey'
    WHEN state = 'NM' THEN 'New Mexico'
    WHEN state = 'NY' THEN 'New York'
    WHEN state = 'NC' THEN 'North Carolina'
    WHEN state = 'ND' THEN 'North Dakota'
    WHEN state = 'OH' THEN 'Ohio'
    WHEN state = 'OK' THEN 'Oklahoma'
    WHEN state = 'OR' THEN 'Oregon'
    WHEN state = 'PA' THEN 'Pennsylvania'
    WHEN state = 'RI' THEN 'Rhode Island'
    WHEN state = 'SC' THEN 'South Carolina'
    WHEN state = 'SD' THEN 'South Dakota'
    WHEN state = 'TN' THEN 'Tennessee'
    WHEN state = 'TX' THEN 'Texas'
    WHEN state = 'UT' THEN 'Utah'
    WHEN state = 'VT' THEN 'Vermont'
    WHEN state = 'VA' THEN 'Virginia'
    WHEN state = 'WA' THEN 'Washington'
    WHEN state = 'WV' THEN 'West Virginia'
    WHEN state = 'WI' THEN 'Wisconsin'
    WHEN state = 'WY' THEN 'Wyoming'
    ELSE state
  END;
  
  
  
  
  
-- Replace column values

UPDATE commoditydetail
SET country = 
  CASE 
    WHEN country = 'AU' THEN 'Australia'
    WHEN country = 'CA' THEN 'Canada'
    WHEN country = 'FR' THEN 'France'
    WHEN country = 'GB' THEN 'United Kingdom'
    WHEN country = 'IM' THEN 'Isle of Man'
    WHEN country = 'NL' THEN 'Netherlands'
    WHEN country = 'SE' THEN 'Sweden'
    WHEN country = 'US' THEN 'United States'
    WHEN country = 'ZA' THEN 'South Africa'
    ELSE country
  END;
  
  
  
  
  
--- Use TRIM on columns

UPDATE commoditydetail
SET commodity_description = TRIM(commodity_description);





-- Add a new column

ALTER TABLE commoditydetail
ADD COLUMN commodityname VARCHAR(255);

-- Fill the new column with the first three words from COMMODITY_DESCRIPTION





UPDATE commoditydetail
SET commodityname = 
  TRIM(
    REGEXP_REPLACE(
      COALESCE(NULLIF(SPLIT_PART(commodity_description, ' ', 1), ''), '') || ' ' ||
      COALESCE(NULLIF(SPLIT_PART(commodity_description, ' ', 2), ''), '') || ' ' ||
      COALESCE(NULLIF(SPLIT_PART(commodity_description, ' ', 3), ''), ''),
      '\s+',
      ' ',
      'g'
    )
  );
  
  
  
  
  
--- Delete one letter in a column

UPDATE commoditydetail
SET commodityname = 
  TRIM(TRAILING ',' FROM commodityname);
  
  
--- Data Final for Analysis

select * from commoditydetail
SELECT *
FROM commoditydetail
WHERE country != 'United States';



