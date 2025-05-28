-- Query 1

create view shippedVSCustDemand as
SELECT CustomerD.customer, CustomerD.item, NVL(SUM(ShipO.qty), 0) AS suppliedQty, CustomerD.qty AS demandQty
FROM customerDemand CustomerD
LEFT JOIN shipOrders ShipO ON CustomerD.customer = ShipO.recipient AND CustomerD.item = ShipO.item
GROUP BY CustomerD.customer, CustomerD.item, CustomerD.qty
ORDER BY CustomerD.customer, CustomerD.item;



-- Query 2
create view totalManufItems as 
SELECT item, SUM(qty) AS totalManufQty
FROM manufOrders
GROUP BY item
ORDER BY item;


-- Query 3
create view matsUsedVsShipped as
	select RequiredQ.manuf, RequiredQ.matItem, RequiredQ.requiredQty, nvl(sum(ShipOrder.qty),0) as shippedQty
	from(select manufactureOrders.manuf as manuf , billMaterial.matItem as matItem, sum( manufactureOrders.qty * billMaterial.QtyMatPerItem) as requiredQty
	from manufOrders manufactureOrders,billOfMaterials billMaterial
	where manufactureOrders.item = billMaterial.prodItem
	group by manufactureOrders.manuf, billMaterial.matItem) RequiredQ left outer join shipOrders ShipOrder on RequiredQ.manuf = ShipOrder.recipient and RequiredQ.matItem = ShipOrder.item
	group by RequiredQ.manuf, RequiredQ.matItem,RequiredQ.requiredQty
	order by RequiredQ.manuf, RequiredQ.matItem
	;



-- Query 4
create view producedVsShipped as
	select	manufacturerOrder.item as item, manufacturerOrder.manuf as manuf,nvl(sum(distinct shipOrder.qty),0) as shippedOutQty, manufacturerOrder.qty as  orderedQty
	from manufOrders manufacturerOrder left outer join shipOrders shipOrder on manufacturerOrder.item = shipOrder.item and manufacturerOrder.manuf = shipOrder.sender
	group by manufacturerOrder.item, manufacturerOrder.manuf, manufacturerOrder.qty
	order by manufacturerOrder.item, manufacturerOrder.manuf
	;



-- Query 5
create view suppliedVsShipped as
	select	supplier__Order.item as item, supplier__Order.supplier as supplier, supplier__Order.qty as suppliedQty, nvl(sum(distinct shiporder__.qty),0) as shippedQty
	from supplyOrders supplier__Order left outer join shipOrders shiporder__ on supplier__Order.item = shiporder__.item and supplier__Order.supplier = shiporder__.sender
	group by supplier__Order.item, supplier__Order.supplier, supplier__Order.qty
	order by supplier__Order.item, supplier__Order.supplier
	;


-- Query 6
create view perSupplierCost as
	select supd.supplier,
	nvl((case
		when calc.totalcost<supd.amt1 then calc.totalcost
		when calc.totalcost>supd.amt2 then ((supd.amt1+(supd.amt2-supd.amt1)*(1-supd.disc1))+(calc.totalcost - supd.amt2)*(1-supd.disc2))
		when calc.totalcost>supd.amt1 and calc.totalcost<supd.amt2 then (supd.amt1+(calc.totalcost - supd.amt1)*(1-supd.disc1))
	end),0) as cost
	from (select supo.supplier as supplier, sum(supo.qty*supup.ppu) as totalcost
		from supplyOrders supo, supplyUnitPricing supup
		where supo.item = supup.item and supo.supplier = supup.supplier
		group by supo.supplier) calc right outer join supplierDiscounts supd on calc.supplier = supd.supplier
	order by supd.supplier
	;


-- Query 7
create view perManufCost as
	select manudisc.manuf,
	nvl((case
	when queryseven.totalcost < manudisc.amt1 then queryseven.totalcost
	when queryseven.totalcost > manudisc.amt1 then (manudisc.amt1+(queryseven.totalcost - manudisc.amt1)*(1-manudisc.disc1))
	end),0) as cost
	from (select mnfo.manuf as manuf, sum(mnfup.setUpCost+(mnfo.qty*mnfup.prodCostPerUnit)) as totalcost
		from manufOrders mnfo, manufUnitPricing mnfup
		where mnfo.item = mnfup.prodItem and mnfo.manuf = mnfup.manuf
		group by mnfo.manuf) queryseven right outer join manufDiscounts manudisc on queryseven.manuf = manudisc.manuf
	order by manudisc.manuf
	;



-- Query 8
create view perShipperCost as
	select sp.shipper,
	nvl(sum(greatest((case
	when calc.basecost<sp.amt1 then calc.basecost
	when calc.basecost>sp.amt2 then ((sp.amt1+(sp.amt2-sp.amt1)*(1-sp.disc1))+(calc.basecost - sp.amt2)*(1-sp.disc2))
	when calc.basecost>sp.amt1 and calc.basecost<sp.amt2 then (sp.amt1+(calc.basecost - sp.amt1)*(1-sp.disc1))
	end),sp.minPackagePrice)),0) as cost
	from (select ship_ord.shipper, BE1.shipLoc as fromloc, BE2.shipLoc as toloc , sum(distinct ship_ord.qty*itm.unitWeight*ship_prc.pricePerLb) as basecost
		from shipOrders ship_ord, busEntities BE1, busEntities BE2, items itm, shippingPricing ship_prc
		where ship_ord.sender = BE1.entity and ship_ord.recipient = BE2.entity and ship_ord.item = itm.item and ship_ord.shipper = ship_prc.shipper and BE1.shipLoc = ship_prc.fromloc and BE2.shipLoc = ship_prc.toloc
		group by ship_ord.shipper, BE1.shipLoc, BE2.shipLoc) calc right outer join shippingPricing sp on calc.shipper = sp.shipper and calc.fromloc = sp.fromloc and calc.toloc = sp.toloc
	group by sp.shipper
	order by sp.shipper
	;


-- Query 9
create view totalCostBreakDown as

	select supplyCost__.cost as supplyCost, manufacturingCost.cost as manufCost,  ship_cost1.cost as shippingCost, (supplyCost__.cost+manufacturingCost.cost+ship_cost1.cost) as totalCost
	from(select sum(sup_cost.cost) as cost from perSupplierCost sup_cost) supplyCost__, (select sum(manf_cost.cost) as cost from  perManufCost manf_cost)
	manufacturingCost, (select sum(ship_cost.cost) as cost from perShipperCost ship_cost) ship_cost1
	;



-- Query 10
create view customersWithUnsatisfiedDemand as
	select distinct selectQuery.customer
	from(select customer_d.customer,customer_d.item, nvl(sum(distinct ship_order.qty),0) as recieved
	from customerDemand customer_d left outer join shipOrders ship_order on customer_d.customer = ship_order.recipient and customer_d.item = ship_order.item
	group by customer_d.customer,customer_d.item
	order by customer_d.customer) selectQuery,customerDemand customerDemand_
	where customerDemand_.item = selectQuery.item and customerDemand_.customer = selectQuery.customer and customerDemand_.qty>selectQuery.recieved
	order by selectQuery.customer
	;



-- Query 11
create view suppliersWithUnsentOrders as
SELECT DISTINCT Supply_order.supplier
FROM supplyOrders Supply_order
LEFT JOIN (
    SELECT item, sender AS supplier, SUM(qty) AS total_shipped
    FROM shipOrders
    GROUP BY item, sender
) Ship_ ON Supply_order.item = Ship_.item AND Supply_order.supplier = Ship_.supplier
WHERE Supply_order.qty > NVL(Ship_.total_shipped, 0)
ORDER BY Supply_order.supplier;




-- Query 12
create view manufsWoutEnoughMats as
	select distinct Req.manuf
	from (select manu_ord.manuf, BM.matitem, sum(distinct manu_ord.qty * BM.QtyMatPerItem) as required
	from manufOrders manu_ord, billOfMaterials BM
	where manu_ord.item = BM.prodItem
	group by manu_ord.manuf, BM.matitem) Req,
	(select Test.manuf, Test.item, nvl(sum(distinct SO2.qty),0) as recieved
	from (select mo2.manuf, BM2.matitem as item
		from manufOrders MO2, billOfMaterials BM2 
		where MO2.item = BM2.prodItem
		) Test left outer join shipOrders SO2 on Test.Item = SO2.item and SO2.recipient = Test.manuf
	group by Test.manuf, Test.item) Got 
	where Req.manuf = Got.manuf and Req.matItem = Got.Item and Req.required > Got.recieved
	order by Req.manuf
	;

-- Query 13
create view manufsWithUnsentOrders as
	select distinct manufacturerOr_.manuf
	from(select manufacturerOr.manuf, manufacturerOr.item, nvl(sum(ship_o.qty),0) as sent
	from manufOrders manufacturerOr left outer join shipOrders ship_o on manufacturerOr.manuf = ship_o.sender and manufacturerOr.item = ship_o.item
	group by manufacturerOr.manuf,manufacturerOr.item
	order by manufacturerOr.manuf) calc, manufOrders manufacturerOr_
	where manufacturerOr_.manuf = calc.manuf and manufacturerOr_.item = calc.item and manufacturerOr_.qty > calc.sent
	;



