-- Showing all columns for the table 
SELECT *
FROM PortfolioProject.dbo.HousingData

--Converting the SaleDate column to standardize Date format 
SELECT SaleDate, CONVERT(Date, SaleDate) AS ConvertedDate
FROM PortfolioProject.dbo.HousingData

--Updating standardize Date format on the HousingData Table
UPDATE PortfolioProject.dbo.HousingData
SET SaleDate = CONVERT(DATE, SaleDate) -- This update did not work 

-- An Alternative
-- Adding column(SaleDateConverted) on the HousingData Table 
ALTER TABLE PortfolioProject.dbo.HousingData
ADD SaleDateConverted DATE  

-- Converting and Updating SaleDate into SaleDateConverted (standardize Date format)
UPDATE PortfolioProject.dbo.HousingData
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Comparing the table to populate property address having null
Select FirstHousing.ParcelID, FirstHousing.PropertyAddress,
	SecondHousing.ParcelID, SecondHousing.PropertyAddress,	
	ISNULL(FirstHousing.PropertyAddress, SecondHousing.PropertyAddress) --Checks the FirstHousing.PropertyAddress values that is null and replaceses it with values in SecondHousing.PropertyAddress
FROM PortfolioProject.dbo.HousingData FirstHousing
JOIN PortfolioProject.dbo.HousingData SecondHousing
	ON FirstHousing.ParcelID = SecondHousing.ParcelID
	AND FirstHousing.[UniqueID ] <> SecondHousing.[UniqueID ]
WHERE FirstHousing.PropertyAddress IS NULL
	         
-- Updating the property address where the value is null with vaule from the second housing 
UPDATE FirstHousing
SET PropertyAddress = ISNULL(FirstHousing.PropertyAddress, SecondHousing.PropertyAddress)
FROM PortfolioProject.dbo.HousingData FirstHousing
JOIN PortfolioProject.dbo.HousingData SecondHousing
	ON FirstHousing.ParcelID = SecondHousing.ParcelID
	AND FirstHousing.[UniqueID ] <> SecondHousing.[UniqueID ]
WHERE FirstHousing.PropertyAddress IS NULL

--Splitting Address into individual Columns(Address, City, State) 1st Approach 
SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) - 1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.HousingData

--Create a column PropertySplitAddress
ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitAddress Nvarchar(255);

--Update the PropertySplitAddress column with the values
UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) - 1)

--Create a column PropertySplitCity
ALTER TABLE PortfolioProject.dbo.HousingData
ADD PropertySplitCity Nvarchar(255);

--Update the PropertySplitCity column with the values
UPDATE PortfolioProject.dbo.HousingData
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN(PropertyAddress))

--Confirming the updates on the new column referencing the propertyAddress
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM PortfolioProject.dbo.HousingData

--View all OwnerAddress on the Table 
SELECT OwnerAddress
FROM PortfolioProject.dbo.HousingData

--Splitting Address into individual Columns(Address, City, State) 2nd Approach
SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'), 3),
PARSENAME (REPLACE(OwnerAddress,',','.'), 2),
PARSENAME (REPLACE(OwnerAddress,',','.'), 1)
FROM PortfolioProject.dbo.HousingData

--Creating new column names for owner address split
ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE PortfolioProject.dbo.HousingData
ADD OwnerSplitState Nvarchar(255)

--Updating the newly created columns with the data for Address,citty and state
UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE PortfolioProject.dbo.HousingData
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress, ',', '.'), 1)

--Confirming the update on the new columns referencing the OwnerAddress
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject.dbo.HousingData

--Reviewing the count of values in SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.HousingData
GROUP BY SoldAsVacant



--Writing the query to update the HousingData Table 
SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.HousingData

-- Updating the HousingData table 
Update PortfolioProject.dbo.HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-- Checking for duplicates 
WITH RowNumCTE AS (
	--These queries identifies rows with duplicate column by creating a column (row_num)
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num	
	FROM PortfolioProject.dbo.HousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 -- This shows the duplicate rows (row_num > 1) The total duplicate was 104
ORDER BY PropertyAddress

--Deleting the duplicates
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num	
	FROM PortfolioProject.dbo.HousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- Confirming the duplicates have been deleted 
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					PropertyAddress,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num	
	FROM PortfolioProject.dbo.HousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Deleting columns that are not needed 
ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict 


--Rename column SaleDateConverted, PropertySplitAddress, PropertySplitCity, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
