--cleaning data in sql queries


select * from public."NashvilleHousing";

----------------------------------------------------------------

--Standardize date format
select saledate from public."NashvilleHousing";


---populate property address
with popadd(parcelid,propadd)
as
(select a.parcelid, b.propertyaddress as propadd
from public."NashvilleHousing" a
join public."NashvilleHousing" b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null)
--select * from popadd

update public."NashvilleHousing"
set propertyaddress = popadd.propadd
from popadd
--from public."NashvilleHousing" a
--join public."NashvilleHousing" b
--on a.parcelid = b.parcelid
--and a.uniqueid <> b.uniqueid
where propertyaddress is null and propertyaddress = popadd.parcelid

select a.parcelid,a.propertyaddress,b.parcelid, b.propertyaddress as propadd
from public."NashvilleHousing" a
join public."NashvilleHousing" b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null



---------------------------------------------------------------

---Breaking out address into individual columns
select split_part(propertyaddress, ',',2 ) as address
from public."NashvilleHousing"

alter table public."NashvilleHousing"
add column  propertysplitaddress  varchar

alter table public."NashvilleHousing"
add column  propertysplitcity  varchar

update public."NashvilleHousing"
set propertysplitaddress = split_part(propertyaddress, ',',1 )

update public."NashvilleHousing"
set propertysplitcity = split_part(propertyaddress, ',',2 )

select split_part(owneraddress, ',',3 ) as address
from public."NashvilleHousing"
----------------------------------------------------------------------

---breaking owner address into individual columns
alter table public."NashvilleHousing"
add column  ownersplitaddress  varchar;

alter table public."NashvilleHousing"
add column  ownersplitcity  varchar;

alter table public."NashvilleHousing"
add column  ownersplitstate  varchar;

update public."NashvilleHousing"
set ownersplitaddress = split_part(owneraddress, ',',1 );

update public."NashvilleHousing"
set ownersplitcity = split_part(owneraddress, ',',2 );

update public."NashvilleHousing"
set ownersplitstate = split_part(owneraddress, ',',3 );

-----------------------------------------------------------
select soldasvacant,
case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from public."NashvilleHousing"
---change y and n to yes and no
update public."NashvilleHousing"
set soldasvacant = case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

---checking if all replacement took place
select distinct(soldasvacant), count(soldasvacant)
from public."NashvilleHousing"
group by soldasvacant

----------------------------------------------------------
---remove duplicates
with RowNumCte 
as(
	select *, row_number() 
over(
partition by parcelid,propertyaddress,saleprice,saledate,legalreference order by uniqueid) row_num
from public."NashvilleHousing"
)
select * from RowNumCte where row_num > 1

delete from public."NashvilleHousing" 
where uniqueid in (select uniqueid from RowNumCte where row_num > 1)

----------------------------------------------------------
---delete unused columns
alter table public."NashvilleHousing"
drop column saledate,
drop column owneraddress,
drop column propertyaddress,
drop column taxdistrict;


----------------------------------------------------------

select * from public."NashvilleHousing"


