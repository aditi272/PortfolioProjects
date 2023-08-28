/*Using Nashville Hosuing Data for Data Cleaning */
/* 
cleaning data in sql queries
*/

-- Standardize Date Format
/* --------------------------------------------------------------------------------------*/
select SaleDate, date_format(str_to_date(SaleDate,'%M %e, %Y'),'%Y-%m-%d') from housing_data
;

update housing_data 
set SaleDate = date_format(str_to_date(SaleDate,'%M %e, %Y'),'%Y-%m-%d');

select SaleDate from housing_data
;
/* --------------------------------------------------------------------------------------*/
-- populate property address data

 UPDATE housing_data a
JOIN housing_data b
  ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';

 
select a.ParcelID ,a.PropertyAddress ,b.ParcelID,b.PropertyAddress
from housing_data a
JOIN housing_data b
  ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID;
  /* --------------------------------------------------------------------------------------*/
-- break out address into individual( address, city, state)

SELECT 
    PropertyAddress,
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS address,
    REVERSE(SUBSTRING_INDEX(REVERSE(PropertyAddress), ',', 1)) AS city
FROM
    housing_data;
    
alter table housing_data
add column PropertySplitAddress varchar(100);

update  housing_data
set PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

alter table housing_data
add column PropertySplitCity varchar(100);

update  housing_data
set PropertySplitCity = REVERSE(SUBSTRING_INDEX(REVERSE(PropertyAddress), ',', 1));


SELECT 
    OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) as address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS city,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS state
    
FROM
    housing_data;
    
alter table housing_data
add column OwnerSplitAddress varchar(100);

update  housing_data
set OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1) ;

alter table housing_data
add column OwnerSplitCity varchar(100);

update  housing_data
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

alter table housing_data
add column OwnerSplitState varchar(100);

update  housing_data
set OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);
/* --------------------------------------------------------------------------------------*/
-- change Y and N to Yes and No in SoldAsVacant



update housing_data
set  SoldAsVacant = 
CASE
    WHEN SoldAsVacant = 'N' THEN  'No'
    WHEN SoldAsVacant = 'Y' THEN  'Yes'
    ELSE SoldAsVacant
    
END
;

select SoldAsVacant from housing_data;


/* --------------------------------------------------------------------------------------*/
-- removing duplicates
with RowNumCTE as(
select * , row_number() over(
Partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by 
UniqueID

)  row_num
from housing_data
)
DELETE from RowNumCTE
where row_num > 1;

/* --------------------------------------------------------------------------------------*/
-- deleting unused columns
alter table housing_data
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;



