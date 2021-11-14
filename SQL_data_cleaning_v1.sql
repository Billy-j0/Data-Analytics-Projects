-- Data Cleaning in SQL


Select * 
From portfolio_project.dbo.NashvilleHousing


-- Standardize Date Format



Select SaleDateConverted, Convert(Date,SaleDate)
From portfolio_project.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date ;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)



-- Populate Property Address Data



Select *
From portfolio_project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.NashvilleHousing a
Join portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolio_project.dbo.NashvilleHousing a
Join portfolio_project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out address into individual columns (Address, City, State)


--Property Address


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, Len(PropertyAddress)) as City
From portfolio_project.dbo.NashvilleHousing



Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255) ;

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255) ;

Update NashvilleHousing
Set PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, Len(PropertyAddress))



--Owner Adress



Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255) ;


Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From portfolio_project.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255) ;

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255) ;

Update NashvilleHousing
Set OwnerSplitCity  = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255) ;

Update NashvilleHousing
Set OwnerSplitState  = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



--Changing Y and N to Yes and No in 'Sold as vacant' field



Select Distinct(SoldAsvacant), Count(SoldAsVacant)
From portfolio_project.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
From portfolio_project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END



-- Removing duplicates



WITH RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by
	UniqueID
	) row_num
From portfolio_project.dbo.NashvilleHousing
)
Delete 
From RowNumCTE
Where row_num > 1



-- Removing Unused Colums



Alter Table portfolio_project.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select * 
From portfolio_project.dbo.NashvilleHousing