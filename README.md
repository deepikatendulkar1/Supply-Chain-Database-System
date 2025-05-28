# 🚚 Supply Chain Database System

This project showcases a relational database system for modeling a collaborative supply chain involving suppliers, manufacturers, shippers, and customers. It includes a well-structured schema and advanced SQL views to support analytics across production, logistics, and demand fulfillment.

---

## 🛠️ Tools & Technologies

- SQL (Relational Queries, Views, Constraints)
- Oracle Database
- Optional: Python for query testing
- ER Diagram tools (ER included in PDF)

---

## 📁 Project Structure

| File                  | Description                                                  |
|-----------------------|--------------------------------------------------------------|
| `database_schema.pdf` | ER diagram + SQL schema (tables with constraints)            |
| `analytical_views.sql`| SQL views for answering 13 analytics questions               |

---

## 🧠 System Overview

This database simulates an end-to-end supply chain system with multiple business entities, tracking inventory, costs, and logistics across different operations.

### 🧩 Problem Statement

This system models a real-world supply chain environment involving four key entities:
- Suppliers who provide raw materials
- Manufacturers who produce goods using those materials
- Shippers who transport items between parties
- Customers who place item demands

Each product can be composed of multiple materials, and entities can interact in various ways:
- Suppliers can ship directly to customers or to manufacturers
- Manufacturers use a bill of materials (BOM) to produce items and fulfill customer demand
- Shippers calculate delivery cost based on item weight and route, with support for volume-based discounts
- Orders are placed separately for supply, manufacturing, and shipping

The system supports:
- Tracking item quantities, weights, and relationships
- Enforcing data integrity with constraints and keys
- Calculating costs (including multi-tier discounts)
- Identifying fulfillment gaps like unshipped orders or unsatisfied demand

---

## 📷 ER Diagram

The ER diagram and all table definitions are included in `database_schema.pdf`. It outlines the relationships between suppliers, manufacturers, customers, shippers, and items involved in the supply chain.

---

## 🔍 Sample Views Explained

1. `shippedVsCustDemand` – Matches quantities shipped to customers against demand.
2. `totalManufItems` – Aggregates ordered quantities of manufactured products.
3. `matsUsedVsShipped` – Checks if manufacturers received required materials.
4. `producedVsShipped` – Compares manufactured items vs. items actually shipped.
5. `suppliedVsShipped` – Verifies if supplier shipments matched supply orders.
6. `perSupplierCost` – Calculates cost of items supplied with volume discounts.
7. `perManufCost` – Computes cost of manufacturing orders with discount tiers.
8. `perShipperCost` – Determines total shipping cost per shipper with weight-based pricing and discounts.
9. `totalCostBreakdown` – Returns the total cost of supply, manufacturing, and shipping.
10. `customersWithUnsatisfiedDemand` – Lists customers whose demand was not fully met.
11. `suppliersWithUnsentOrders` – Identifies suppliers with incomplete shipments.
12. `manufsWoutEnoughMats` – Flags manufacturers who didn't receive enough materials.
13. `manufsWithUnsentOrders` – Finds manufacturers whose produced items weren’t fully shipped.

---

## ✅ How to Run

1. Refer to `database_schema.pdf` for the ER diagram and SQL `CREATE TABLE` definitions used in this system.
2. Run the view definitions in `analytical_views.sql`.
3. (Optional) Use JSON files and scripts if testing setup is available.

---

## 📬 Let’s Connect

If you're working on backend systems, data pipelines, or enterprise applications — I’d love to connect and collaborate!

🔗 [LinkedIn](https://www.linkedin.com/in/deepika-tendulkar-a88bb8166/)  
📫 Email: deepikatenduulkar5@gmail.com

---

*Thanks for checking out this project!*
