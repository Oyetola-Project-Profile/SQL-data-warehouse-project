
## General Principle
- Naming Conventions: Use snake_case, with lowercase letters and underscore **`(_)`** to separate each word.
- Avoid Reserved Words: We do not use SQL reserved words as object names.
----
### Table Naming Conventions

#### Bronze Rules
- All names must start with the source system name, and table names must match their original names without renaming them.
- **`<sourcesystem>_<entity>`**
	- **`<sourcesystem>`**:Name of the source system (e.g., crm, erp).
	- **`<entity>`**:Exact table name from the source system.
	- Example: crm_customer_info, i.e., customer information from the CRM system.

#### Silver Rules
- All names must start with the source system name, and table names must match their original names without renaming them.
- **`<sourcesystem>_<entity>`**
	- **`<sourcesystem>`**:Name of the source system (e.g., crm, erp).
	- **`<entity>`**:Exact table name from the source system.
	- Example: crm_customer_info, i.e., customer information from the CRM system.

#### Gold Rules
- All names must use meaningful, business names for the tables, starting with the category prefix.
- **`<category>_<entity>`**
	- **`<category>`**: Describes the role of the table, such as dim (dimension) or fact (fact table).
	- **`<entity>`**: Describes the name of the table, which is aligned with the business domain. (e.g. customers, products, sales).
	- Examples: dim_customers and fact_sales

----
### Column Naming Conventions

#### Surrogate Keys
- All primary keys in dimension tables must use the suffix _key.
- **`<table_name>_key`**
	- **`<table_name>`**:Refers to the name of the table or entity the key belongs to.
	- _key:A suffix indicating that this column is a surrogate key.
	- Example:customer_key (refers to surrogate key in a dim_customers table.

#### Technical Columns
- All technical columns must start with the prefix dwh_, followed by a descriptive name indicating the column's purpose.
- **`dwh_<column_name>`**
	- dwh: Prefix exclusively for system-generated metadata.
	- **`<column_name>`**: Descriptive name indicating the column's purpose.
	- Example: dwh_load_date (refers to a system-generated column used to store the date when the record was loaded).

#### Stored Procedure
- All stored procedures used for loading data must follow the naming pattern:
- **`load_<layer>`**.
	- **`<layer>`**: Represents the layer being loaded, such as bronze, silver or gold.
	- Examples:
		+ load_bronze(Stored procedure for loading into bronze layer)
		+ load_silver(Stored procedure for loading into silver layer)








 








