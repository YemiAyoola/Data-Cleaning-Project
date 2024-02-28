

--Cleaning Data inSQL QUeries

Select *
From PortfolioProject..NashvilleHousing

--Standardizing Date Format

Select SaleDate, convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = convert(Date,SaleDate)

alter table nashvillehousing
add SaleDateConverted Date
update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

--Populate Property address data

Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.propertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null


	---Breaking out address into individual column (address, city, state)

Select PropertyAddress
From PortfolioProject..NashvilleHousing
---where PropertyAddress is null
order by ParcelID

Select 
Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = Substring(PropertyAddress, charindex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',','.'), 3)
,Parsename(Replace(OwnerAddress, ',','.'), 2)
,Parsename(Replace(OwnerAddress, ',','.'), 1)
From PortfolioProject..NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'), 3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'), 2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'), 1)

Select *
From PortfolioProject..NashvilleHousing

--Changing Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(Soldasvacant), count(Soldasvacant)
From PortfolioProject..NashvilleHousing
group by Soldasvacant

Select Soldasvacant
, case when Soldasvacant = 'Y' then 'Yes'
	   when Soldasvacant = 'N' then 'No'
	   else Soldasvacant
	   end
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case when Soldasvacant = 'Y' then 'Yes'
	   when Soldasvacant = 'N' then 'No'
	   else Soldasvacant
	   end


---Remove duplicates

With RowNumCTE as(
Select*,
	Row_Number() Over (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by
				UniqueID)
				row_num
From PortfolioProject..NashvilleHousing)
--order by ParcelID
Delete
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict