insert into INVOICES (ID, CLIENT_ID, ACCOUNT_ID, PAYMENT_SYSTEM_IDENTIFIER, CREATED_AT, IS_PAID, ACCOUNT_NUMBER, BRAND_ID, TENANT_ID)
values (
(select max(ID)+1 from INVOICES),
        1,1,'payport_invoice_kgs',CURRENT_TIMESTAMP,'N',1,'chesnok','chesnok.kg');

select max(ID) from INVOICES