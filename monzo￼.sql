￼
-- Creating the account_dim

create table analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.account_dim (
account_key string not null,
account_id string not null,
user_key string not null,
account_type string,
account_opened_ts timestamp,
account_opened_date_key date,
account_closed_ts timestamp,
account_closed_date_key date,
account_reopened_ts timestamp,
account_reopened_date_key date,
created_at timestamp,
updated_at timestamp
)

-- Creating the user_dim
create table analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_dim (
user_key string not null,
user_id string not null,
user_first_name string not null,
user_last_name string,
user_dob string,
user_email string,
user_phone string,
user_address_1 string,
user_address_2 string,
user_postal_code string,
user_city string,
user_state string,
user_country string,
created_at timestamp,
updated_at timestamp
)

-- Creating the user_account_transaction_fact
create table analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_account_transaction_fact (
user_account_transaction_key string not null,
account_key string not null,
user_key string not null,
account_type string,
account_created_ts timestamp,
transaction_num int64,
transaction_amount_pounds numeric,
local_currency_used string,
transaction_date_key date,
transaction_ts timestamp,
user_demographic_key string,
audit_key string,
created_at timestamp,
updated_at timestamp
)

-- Creating the user_demographic_dim
create table analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_demographic_dim (
user_demographic_key string,
age_group string,
gender string
)

-- Creating the user_transaction_7d_snapshot
-- This can be used for directly querying the 7d metric
create table analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_transaction_7d_snapshot 
(
transaction_7d_period date,
total_7d_metric numeric,
account_type string,
local_currency_used string,
age_group string,
gender string,
created_at timestamp,
updated_at timestamp
)


-- Inserting data into user_dim
-- inserting uuid as the surrogate key. 
insert into `analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_dim`
 (user_key, user_id, user_first_name, created_at, updated_at)
SELECT generate_uuid(), user_id_hashed, 'ABC', current_timestamp(), current_timestamp() 
from analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.staging_account_created

-- Inserting data into oaccount_dim
insert into `analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.account_dim`
 (account_key, account_id, user_key, account_type, account_opened_ts, account_reopened_ts, account_closed_ts,
 account_opened_date_key, account_reopened_date_key, account_closed_date_key,
 created_at, updated_at)
SELECT 
generate_uuid(),
cr.account_id_hashed,
user_key,
account_type,
created_ts, reopened_ts, closed_ts,
safe_cast(FORMAT_DATE('%Y%m%d', created_ts) as date) , 
safe_cast(FORMAT_DATE('%Y%m%d', reopened_ts) as date), 
safe_cast(FORMAT_DATE('%Y%m%d', closed_ts) as date),
current_timestamp(), 
current_timestamp() 
from analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.staging_account_created cr
left join analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_dim ud on ud.user_id = cr.user_id_hashed
left join analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.staging_account_reopened re on cr.account_id_hashed = re.account_id_hashed
left join analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.staging_account_closed cl on cr.account_id_hashed = cl.account_id_hashed



-- Inserting data into user_demographic_dim
insert into analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_demographic_dim
(user_demographic_key,age_group, gender)
(select generate_uuid(),'30-35','Other')

-- Inserting data into user_account_transaction_fact from the other dimension tables that we just filled data into.
insert into `analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_account_transaction_fact`
 (user_account_transaction_key, account_key,user_key,account_type, account_created_date_key, account_created_ts, 
transaction_num, transaction_date_key,
 created_at, updated_at)
SELECT 
generate_uuid(), 
ad.account_key,
ud.user_key,
ad.account_type,
ad.account_opened_date_key,
ad.account_opened_ts,
sat.transactions_num,
sat.date,
current_timestamp(), 
current_timestamp() 
from analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_dim ud
left join analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.account_dim ad on ud.user_key = ad.user_key
left join analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.staging_account_transactions sat on sat.account_id_hashed = ad.account_id

-- Inserting data into user_transaction_7d_snapshot from the user_account_transaction_fact table that we just filled data into.
-- Assuming that there are transactions everyday.
-- I am taking a lag of 7 days, and then adding the transaction num and amount for all the users over the period of that 7 days.
-- For getting the 7d metric, the users can use this table directly and slice and dice on cohorts, account_types, age, gender, local_currency etc.
-- I would have used something like mackaroo.com to create the fake data for the amount,currency, age and gender 
-- and would have also created a date_dim but unfortunately ran out of time.
-- This query is NOT correct. It needs to do the count of the user twice, coz right now it is assuming that one transaction date has aggregated users
-- whihc is not the case. I will try to resolve it ASAP.

insert into analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_transaction_7d_snapshot
(
transaction_7d_period,
account_type,
total_7d_metric,
local_currency_used,
age_group,gender,
created_at,
updated_at
)
select distinct
lag(transaction_date_key,7) over(order by transaction_date_key asc) as transaction_7d_period,
account_type,
cast(count(user_key) over(order by transaction_date_key rows between 7 preceding and current row) /(select count(user_key) from analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_dim) as numeric) as total_7d_metric,
local_currency_used,'','',
current_timestamp(),
current_timestamp()
from analytics-take-home-test.monzo_datawarehouse_take_home_task_TS.user_account_transaction_fact












