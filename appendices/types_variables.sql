USE transactionsample;
SET @varInt = 1;
SET @varDec = 1234.764;
SET @varString = "Hello";
SET @varJSON = '{
  "accountno": "123456",
  "funds": 250.75
}';

SELECT @varInt, @varDec, @varNULL, @varString, @varJSON,JSON_VALID(@varJSON);


drop temporary table if exists foo;
create temporary table foo select @varInt, @varDec, @varNULL, @varString, @varJSON, @varNULL; 
desc foo;