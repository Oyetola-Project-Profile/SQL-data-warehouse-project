# Data Catalog for Gold Layer

## **Overview**

The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for specific business metrics.

---
### **1. gold.dim_customers**

  - **Purpose:** Stores customer details enriched with demographic and geographic data.
  - **Columns:**

|  Column Name  |Data Type  |  Description  |
|---|---|:---|
|customer_key|Int|Surrogate key uniquely identifying each customer record in the dimension table.|
|customer_id|Int|Unique numerical identifier assigned to each customer.|
|customer_number|NVarchar(50)|Alphanumeric identifier representing the customer, used for tracking and referencing.|
|firstname|NVarchar(50)|The customer's first name, as recorded in the system.|
|lastname|NVarchar(50)|The customer's last name or family name.|
|marital_status|NVarchar(50)|The marital status of the customer (e.g., 'Married', 'Single').|
|gender|NVarchar(50)|The gender of the customer (e.g., 'Male', 'Female', 'n/a').|
|country|NVarchar(50)|The country of residence for the customer (e.g., 'France').|
|birthdate|Date|The date of birth of the customer, formatted as YYYY-MM-DD (e.g., 1966-01-19).|
|create_date|Date|The date and time when the customer record was created in the system.|

---
### **2. gold.dim_products**

- **Purpose:** Provides information about the products and their attributes.
- **Columns:**
  
|  Column Name  |Data Type  |  Description  |
|---|---|:---|
|product_key	|Int	|Surrogate key uniquely identifying each product record in the product dimension table.|
|product_id|	Int	|A unique identifier assigned to the product for internal tracking and referencing.|
|product_number	|NVarchar(50)|	A structured alphanumeric code representing the product, often used for categorization or inventory.|
|product_name	|NVarchar(50)|	Descriptive name of the product, including key details such as type, color, and size.|
|category_id	|NVarchar(50)|	A unique identifier for the product's category, linking to its high-level classification.|
|category|	NVarchar(50)	|The broader classification of the product (e.g., Bikes, Components) to group related items.|
|subcategory|	NVarchar(50)	|A more detailed classification of the product within the category, such as product type.|
|maintenance_required	|NVarchar(50)|	Indicates whether the product requires maintenance (e.g., 'Yes', 'No').|
|cost	|Int	|The cost or base price of the product, measured in monetary units.|
|product_line|	NVarchar(50)|	The specific product line or series to which the product belongs (e.g., Road, Mountain).|
|start_date	|Date|	The date when the product became available for sale or use, stored in|


---
### **3. gold.fact_sales**

- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**
  
|  Column Name  |Data Type  |  Description  |
|---|---|:---|
|order_number	|NVarchar(50)	|A unique alphanumeric identifier for each sales order (e.g., 'SO51493').|
|product_key	|Int|	Surrogate key linking the order to the product dimension table.|
|customer_key|	Int|	Surrogate key linking the order to the customer dimension table.|
|order_date|	Date|	The date when the order was placed.|
|shipping_date	|Date	|The date when the order was shipped to the customer.|
|due_date	|Date	|The date when the order payment was due.|
|sales_amount|	Int|	The total monetary value of the sale for the line item, in whole currency units (e.g., 2320).|
|quantity|	Int	|The number of units of the product ordered for the line item (e.g., 1).|
|price	|Int	|The price per unit of the product for the line item, in whole currency units (e.g., 33).|

