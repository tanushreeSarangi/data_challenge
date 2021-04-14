# Monzo Challenge

### Goal :
    To create a very reliable and accurate data model that represents all the different accounts at Monzo.

### Business Process : 
    Processing transaction per user per account.

### Grain : 
    One row per User per Account (as the users can have multiple accounts)

### Fact Table : 
    1. user_account_transaction_fact. This table will include data about the account activities. Each row will indicate transaction per user per account.

### Dimension Tables :
    1. user_dim : will contain information and context about the users
   
    2. account_dim : will contain information and context about the accounts

    3. date_dim : will contain all the dates from the calendar. We could have used the SQL dates directly but they don't contain extra information like Quarter, Holiday, Weekday.

    4. audit_dim : will contain the lineage of the records, so that if there is any error or suspicious data, we can easily track where that record came from.
    
    5. currency_dim(Out of Scope for this project): Since Monzo has users internationally, the users can have different currencies. This would be a currency mapping table.
   
   
### Mini Dimensions :

    1. user_demographic_dim : will contain the age groups and gender combinations.

### 7d periodic user transaction fact table :

    As the main metric that we are trying to find in this case is the 7 days metric. So we can create this periodic accumulation fact table that will answer this question right away and will be very easy for the data analysts and other business users to access and understand.

    We will also have columns like age, gender, city etc., so if the analysts want to analyze according to any of those columns, it will be very easy.

### Ensuring Data Quality :

    1. Column Screening :
    This will take care of the data quality on a column level eg. Null values, data types, date formats, range etc.

    2. Structure Screening :
    This will take care of the referential integrity between the dimension tables and the fact tables. We should not have records in the fact table that do not have any corresponding records in the dimension tables.

    3. Business Rules Screening :
    This will take care of the business process filters eg. The account needs to be opened first to have a transaction, so the account creation date needs to be greater than the transaction data; a closed account cannot have any transactions etc.

### Miscellaneous :
 1. Surrogate Keys : 
   A Surrogate Key is a meaningless incrementing integer key. It is recommended to use these keys rather than the natural keys as these are safer, creates less confusion, doesn't need to change if the business process changes, easier fro insert, updates and deletes in the table.

    We will add the surrogate key to all the dimension and fact tables.



1. Natural Keys : 
    A natural key is a type of unique key in a database formed of attributes that exist and are used in the external world outside the database.

    We will keep the natural keys coming from the application database in the dimension and fact tables, this will make matching the DW data to the application database easier.

3. Fact Tables: Fact tables consists of the measurements, metrics or facts of a business process. These tables contain large amount of rows (narrow tables) and a comparatively less amount of columns.
    
4. Dimension Tables: Dimension tables tell you the what, when, where who, why and how of the data. In simple words, they provide you with the context around a data point.
   
I try to be as verbose as possible when creating the dimension tables. This makes sure to capture the most amount of data and makes it easier to drill down. These tables contain a large number of columns (wide table) and a comparatively less amount of rows.

## Assumptions :
      1. A user can have multiple accounts but an account cannot have multiple users.
      2. All account types have the same attributes.
      
## DATA MODEL :



<img width="768" alt="Screen Shot 2021-04-14 at 1 57 55 AM" src="https://user-images.githubusercontent.com/18383999/114662956-8cd31200-9cc7-11eb-913e-b05a985dc315.png">




### Assumptions :
1. An account can have multiple account holders eg. a joint account
2. All accounts have different account types eg. Cheque, Savings, Lending, Credit etc.
3. Created fake data points for extra data points that might be coming from the source. (eg. First Name, Last Name, email, dob, gender etc.)

## ETL Process :

1. Inserting all the data coming from the source as-is into the staging schema, so that we are constantly doing heavy queries on the source db.
   
2. The first step would be to fill the dimension tables. For this, I used simple insert queries to get the data from the tables provided as well as created some fake data to cover all the data points.
   
3. I made some columns in the dimension tables as 'not null' to use it as a constraint to check that we are always getting the mandatory data points and to use it as a filter to enforce the business logic eg. all the accounts need to be associated with a user.
   
4. The other filters (ideally and realistically they would be on the source/application database), I have tried to put some in the queries when I am inserting the data from source to dimensions.


## If I had more time 
I would have used something like https://www.mockaroo.com for generating fake data for it.  
