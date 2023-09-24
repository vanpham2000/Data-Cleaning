select *
from [PorfolioProject]..[NashvilleHousing]


-- cleaning 

-- standardize Date format

select SaleDate
from [PorfolioProject]..[NashvilleHousing]


ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD TempSaleDate DATE;

update [PorfolioProject]..[NashvilleHousing]
set TempSaleDate = convert(date, SaleDate)

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
DROP COLUMN SaleDate;

--EXEC sp_rename 'MyTable.OldColumn', 'NewColumn', 'COLUMN';

-- populate Property address data


select PropertyAddress
from [PorfolioProject]..[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

select a.[UniqueID ], a.PropertyAddress, a.ParcelID, b.[UniqueID ], b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress, b.PropertyAddress) as IsNulladdress
from [PorfolioProject]..[NashvilleHousing] as a
join [PorfolioProject]..[NashvilleHousing] as b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
from [PorfolioProject]..[NashvilleHousing] as a
join [PorfolioProject]..[NashvilleHousing] as b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- breaking out addres in induvudual items
select PropertyAddress
from [PorfolioProject]..[NashvilleHousing]

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as address, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as state
from [PorfolioProject]..[NashvilleHousing]

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD PropertyAddressT nvarchar(255);

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD PropertyState nvarchar(255);

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as address, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as state
from [PorfolioProject]..[NashvilleHousing]

-- update to new column address
update [PorfolioProject]..[NashvilleHousing]
set PropertyAddressT = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) 
from [PorfolioProject]..[NashvilleHousing]
-- update to new column state
update [PorfolioProject]..[NashvilleHousing]
set PropertyState = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress))
from [PorfolioProject]..[NashvilleHousing]
--see new column
select PropertyAddress, PropertyCity
from [PorfolioProject]..[NashvilleHousing]

-- delete column 
ALTER TABLE [PorfolioProject]..[NashvilleHousing]
DROP COLUMN PropertyAddress;

-- change column name
EXEC sp_rename 'PorfolioProject..NashvilleHousing.PropertyAddressT', 'PropertyAddress', 'COLUMN';
select OwnerAddress
from [PorfolioProject]..[NashvilleHousing]

-- use parce name

select Parsename(Replace(OwnerAddress, ',', '.') ,3), Parsename(Replace(OwnerAddress, ',', '.') ,2),  Parsename(Replace(OwnerAddress, ',', '.') ,1)
from [PorfolioProject]..[NashvilleHousing]

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD OwnerAddressT nvarchar(255);

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD OwnerCity nvarchar(255);

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
ADD OwnerState nvarchar(255);


update [PorfolioProject]..[NashvilleHousing]
set OwnerAddressT = Parsename(Replace(OwnerAddress, ',', '.') ,3),
OwnerCity = Parsename(Replace(OwnerAddress, ',', '.') ,2),
OwnerState =  Parsename(Replace(OwnerAddress, ',', '.') ,1)
from [PorfolioProject]..[NashvilleHousing]

select  OwnerAddress ,OwnerCity ,OwnerState
from [PorfolioProject]..[NashvilleHousing]

ALTER TABLE [PorfolioProject]..[NashvilleHousing]
DROP COLUMN  OwnerAddress;

-- change column name
EXEC sp_rename 'PorfolioProject..NashvilleHousing.OwnerAddressT', 'OwnerAddress', 'COLUMN';

-- change y and n to a yes or no

select SoldAsVacant, count(SoldAsVacant)
,CASE
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end as ChangeinVacant
from [PorfolioProject]..[NashvilleHousing]
group by SoldAsVacant

update [PorfolioProject]..[NashvilleHousing]
set SoldAsVacant = CASE
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from [PorfolioProject]..[NashvilleHousing]


-- see duplicate

with RowDup as(
	select*,
	ROW_NUMBER() over(
	partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	order by UniqueID) row_num

from [PorfolioProject]..[NashvilleHousing]	
)

select* -- delete duplcate by replace with delete but dont in real database
from RowDup
 where row_num > 1
 order by PropertyAddress
)


-- remove unused column
