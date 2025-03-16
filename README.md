# Skincare_Products_Online_Shop

Introduction

This documentation describes the development of a database for an online shop specializing in beauty and skincare products. The primary goal of the database is to support all operations of the online shop, ranging from user and product catalog management to order and payment processing.


Objectives of the Database

1.	User Management:
-	Store information about users, including personal details, contact information, and registration data.
-	Support user authentication and authorization processes.
2.	Product Catalog:
-	Store information about beauty and skincare products, including names, descriptions, prices, categories, brands, and images.
-	Manage inventory.
3.	Order Processing:
-	Support the creation and management of orders, including storing information about orders, order details, and statuses.
-	Manage user carts.
4.	Payment Processing:
-	Store information about payments, including amounts, payment methods, and payment statuses.
-	Link payments to the corresponding orders.
5.	User Reviews:
-	Store user reviews of products, including ratings, comments, and review dates.
6.	Data Analysis (OLAP):
-	Support analytical processes and business reporting through a multidimensional data warehouse.
-	Store historical data using SCD Type 2 for time-based analysis.
-	Provide data for analyzing sales, user behavior, and marketing campaign effectiveness.


Logical Scheme for OLTP Database

Description of each table:

1.	User: Stores information about users of the online shop. Used for user authentication, authorization, and storing contact information.

-	One user can have several orders (Table Order)  =>  entity relationship one-to-many
-	One user can have one cart (Table Cart)   =>  entity relationship one-to-one
-	One user can have several reviews (Table Review)  =>  entity relationship one-to-many

2.	Product: Contains information about beauty and skincare products available for purchase. Used for displaying products on the website, inventory management, and categorization.

-	One product belongs to one category (Table Category)  =>  entity relationship one-to-one 
-	One product can be included in several orders (Table OrderDetail)  =>  entity relationship one-to-many
-	One product may have multiple reviews (Table Review)  =>  entity relationship one-to-many
-	One product can be included in several cart details (Table CartDetail)  =>  entity one-to-many

3.	Category: Stores product categories. Used for classifying products and facilitating search and navigation within the catalog.

-	One product belongs to one category (Table Product)  =>  entity relationship one-to-one 


4.	Order: Contains information about user orders. Used for order management, status tracking, and payment processing.

-	One order is associated with one user (Table User)  =>  entity relationship one-to-one
-	One order can have several order details (Table OrderDetail)  =>  entity relationship one-to-many
-	One order can have one payment (Table Payment) =>  entity relationship one-to-one 

5.	OrderDetail: Stores information about the details of each order, including products, quantities, and prices. Used for calculating the total order cost and managing inventory.

-	Multiple order details refer to one order (Table Order)  =>  entity relationship many-to-one
-	Multiple order details refer to one product (Table Product)  =>  entity relationship many-to-one


6.	Review: Contains user reviews of products. Used for displaying reviews on the website and analyzing product quality.

-	One review belongs to one user (Table User)  =>  entity relationship one-to-one
-	One review belongs to one product (Table Product)  =>  entity relationship one-to-one

7.	Cart: Stores information about user carts. Used for managing the purchase process and adding products to the cart.

-	One cart is associated with one user (Table User)  =>  entity relationship one-to-one
-	One cart can contain several cart details (Table CartDetail)  =>  entity relationship one-to-many

8.	CartDetail: Contains details of products in user carts. Used for displaying cart contents and managing inventory.

-	Multiple cart details belong to one cart (Table Cart)  =>  entity relationship many-to-one
-	Multiple cart parts belong to one product (Table Product)  =>  entity relationship many-to-one

9.	Payment: Stores information about payments associated with orders. Used for tracking payment statuses and processing transactions.

-	One payment is associated with one order (Table Order)  =>  entity relationship one-to-one 



Structure of the OLAP Database

The Data Warehouse consists of dimension tables (9 Dim tables) and fact tables (2 Fact tables). 

In this database in DWH script I have SCD Type 2 function for “DimUsers” : scd_user_dimension_trigger().
scd_user_dimension_trigger() :
o	Purpose: handles the maintenance of Slowly Changing Dimension (SCD) Type 2 for the DimUsers table.
o	Update Operations: When a user record is updated, the function marks the current record as inactive by setting the end_date and current_flag to FALSE.
o	Insert Operations: A new record is inserted with updated values and the current_flag set to TRUE.
o	Ensures that the history of changes to user data is preserved, allowing for time-based analysis of user information.

In this database in DWH script I have function for creating trigger for “Users”: scd_user_dimension_trigger() :
o	Purpose: This trigger is linked to the “Users” table to invoke the scd_user_dimension_trigger() function whenever an insert or update operation occurs on the “Users” table.
o	After Insert or Update: Executes the scd_user_dimension_trigger function to handle the SCD Type 2 logic, ensuring that changes in the Users table are reflected in the DimUsers table.


Data for OLTP Database

For my database, I have four .csv files with data:
•	Users.csv
•	Products.csv
•	Categories.csv
•	Orders.csv


Load data from csv files to OLTP database

I have file “OLTP_loading.sql”, which have function “load_data_from_csv” in script. The “load_data_from_csv” function is designed to facilitate the efficient and error-free loading of data from CSV files into the OLTP database. This function handles the import of user, product, category, and order data from specified CSV files into their respective tables in the database.

The primary purpose of this function is to streamline the data loading process from CSV files into the OLTP database.

Detailed description:
-	The function creates temporary tables (TempUsers, TempProducts, TempCategories, TempOrders) to hold the data temporarily while it's being processed and validated.
-	Data from the CSV files is loaded into the corresponding temporary tables using the COPY command.
-	The function inserts data from the temporary tables into the actual tables (Users, Products, Categories, Orders) in the database. The ON CONFLICT clause ensures that if a conflict arises the existing records are not overwritten.
-	After the data has been successfully inserted into the actual tables, the temporary tables are dropped to clean up and free resources.


Load data from the OLTP Database to OLAP Database

I have file “OLAP_loading.sql”, which have function “transferring_data” in script. The purpose of this script and function is to transfer data from the OLTP database to the OLAP database.

Description:
-	The script uses the postgres_fdw (Foreign Data Wrapper) extension to create a foreign server connection to the OLTP database.
-	Then defines a function “transferring_data” which transfers data from the OLTP database to the OLAP database. This function is responsible for populating the dimension and fact tables in the OLAP schema with the data from the OLTP database.


OLAP Visual report in Power BI

I have file “Skincare_Products_Shop_Analysis.pbix”, which contains my report. 
The report contains four visualizations:
-	Line chart of the count of orders by year
-	Pie chart of sales by product
-	Clustered column chart of number of products by category
-	Table with information about orders

How to run the project of course work

o	Firstly, we need to create OLTP and OLAP databases.
o	In OLTP database run script of this file “OLTP_creation.sql”.
o	Then run script of file “OLTP_loading.sql”.
o	In OLAP database run script of this file “OLAP_creation.sql”.
o	Run script of file “OLAP_loading.sql”.
o	Then open file with Power BI report “Skincare_Products_Shop_Analysis.pbix”.