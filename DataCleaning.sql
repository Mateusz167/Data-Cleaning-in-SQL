/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Nashville_Housing


--------------------------------
--Standarise Data Format
SELECT saleDate, CONVERT(date, SaleDate), dateConverted
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ALTER COLUMN SaleDate DATE

ALTER TABLE Nashville_Housing
ADD DateConverted DATE

Update Nashville_Housing
SET DateConverted = CONVERT(date, SaleDate)


-- Populate Proptery Address data
--Some data in propertyAddress have NULL values, but based on other data we are able to replace these values to the correct address of the proprerty
--To do that we can use ParcelID column and use it to fill in NULL values - Property Adress will be the same for the same ParcelID

SELECT propertyAddress
FROM Nashville_Housing
WHERE propertyAddress IS NULL

SELECT a.ParcelID, a.propertyAddress, b.ParcelID, b.propertyAddress, ISNULL(a.propertyAddress, b.propertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.propertyAddress IS NULL

UPDATE a
SET propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

----Breaking out Address into Individual Columns (Address, City, State)
--1 propertyAddress
SELECT propertyAddress
FROM Nashville_Housing

SELECT
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) - 1) AS Address
, SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress)) AS City
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress) - 1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity Nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress) + 1, LEN(propertyAddress))

Select PropertySplitAddress, PropertySplitCity
FROM Nashville_Housing


-- OwnerAdress
SELECT OwnerAddress
FROM Nashville_Housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Nashville_Housing

--Change Y and N to Yes and No in "Sold as Vacant" filed
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

-- In base dataset there are some 'Y' 'N' in 'SoldAsVacant' column. In order to unify data we can replace its to 'Yes' and 'No' accordingly.

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Checking whether there are any duplicates left
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Nashville_Housing
)
Select *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Delete unsued columns

SELECT *
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress