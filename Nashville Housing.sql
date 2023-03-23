/*

Cleaning Data In SQL

*/
Select *
From 
PortfolioProject..NashvilleHousing;

----------------------------------------------------------------------------------------------------------------


--------Standardize the date format--------
Select SaleDateConvert, CONVERT(Date,SaleDate)
From 
PortfolioProject..NashvilleHousing;

Update NashvilleHousing
Set
	SaleDate = CONVERT(Date,SaleDate);
Select *
From 
PortfolioProject..NashvilleHousing;

-------If above statement doesn't work then use the Alter Table and Update Statements combinations----
Alter Table  NashvilleHousing
Add SaleDateConvert Date;
Update NashvilleHousing
Set
	SaleDateConvert = CONVERT(Date,SaleDate);
----------------------------------------------------------------------------------------------------------------------

---Populate Property Address Data-----
Select  ParcelID,PropertyAddress
From 
PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID;


Select  a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
From 
PortfolioProject..NashvilleHousing as a                        
Join PortfolioProject..NashvilleHousing as b                  -------------------SELF JOIN -----------------------
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From 
PortfolioProject..NashvilleHousing as a                        
Join PortfolioProject..NashvilleHousing as b                  
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;
 
 Select *
From 
PortfolioProject..NashvilleHousing
Where PropertyAddress is null;

-------------------------------------------------------------------------------------------------------------------------------------------
----Breaking out Address into Individual Columns (Address,City,State)---------------
 Select len(PropertyAddress)
From 
PortfolioProject..NashvilleHousing;


Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
From PortfolioProject..NashvilleHousing
;
Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255)
;
Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255)
;
Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
 




 Select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
  PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 From PortfolioProject..NashvilleHousing;

 Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)
;
Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)
;
Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255)
;
Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)



----------------------------------------------------------------------------------------------------------
-----Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then  'No'
	 Else SoldAsVacant
End
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then  'No'
	 Else SoldAsVacant
End



-------------------------------------------------------------------------------------------------------------------------------------------------
---Remove Duplicates-------
With RowNumCTE as (
Select *,
	ROW_NUMBER() Over( 
	Partition By  ParcelID,
	PropertyAddress ,SalePrice,
	SaleDate,LegalReference
	Order by 
	UniqueID) as row_num

From PortfolioProject..NashvilleHousing)
---order by ParcelID
 Select *
 From RowNumCTE
 where row_num > 1
 order by PropertyAddress



 -------------------------------------------------------------------------------------------------------------------------------------

 -------Delete Unused Column----------

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress


Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate


