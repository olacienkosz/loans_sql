# loans_sql
In the sql analysis, I used the financial database, which contains information about loans that have been repaid or not.


Card
A table containing credit card information.

Columns:
card_id - card id,
disp_id - ID of the card holder,
type - card type (classic, gold, etc.),
issued - card issue date.

Disp
The table contains information about the people assigned to the card. 

Columns:
disp_id - ID of the card holder,
client_id - client id,
account_id - account id,
type - card management type (owner or administrator).

Client
The table contains the basic characteristics of the client.

Columns:
client_id - client id,
gender - gender,
birth_date - date of birth,
district_id - id of the district of residence.

District
The table includes district demographics.

Columns:
district_id - id of the district of residence,
A2 - name of the district,
A3 - region,
A4 - the number of residents,
A5 - number of communes with inhabitants below 499,
A6 - number of communes with inhabitants in the years 500-1999,
A7 - number of communes with inhabitants in the years 2000-9999,
A8 - number of communes with inhabitants over > 10,000,
A9 - number of cities,
A10 - ratio of urban to rural inhabitants,
A11 - average salary,
A12 - unemployment rate in 1995,
A13 - unemployment rate in 1995,
A14 - number of entrepreneurs per 1000 inhabitants,
A15 - number of crimes committed in 1995,
A16 - number of crimes committed in 1996.

Account
The table contains information about accounts.

Columns:
account_id - account id,
district_id - id of the district of the branch where the account was created,
frequency - frequency of issuing statements,
date - date of account creation.


Trans
The table contains information about transactions.

Columns:
trans_id - transaction id,
account_id - account id,
date - transaction date,
type - or debit/credit transaction,
operation - transaction type,
amount - transaction amount,
balance - account balance after the transaction,
k_symbol - transaction characteristics,
bank - transaction partner's bank,
account - transaction partner account.

Order
The table contains the characteristics of direct debit.

Columns:
order_id - order id,
account_id - account id,
bank_to - recipient's bank id,
account_to - recipient's account id,
amount - transfer amount,
k_symbol - transaction characteristics.

Loan
The table provides information about the loan status.

Columns:
loan_id - loan id,
account_id - account id,
date - date of loan granting,
amount - loan amount,
duration - loan duration,
payments - monthly payment amount,
status - loan repayment status.
