SET @varInt = 1;
SET @varDec = 1234.764;
SET @varFloa = 0.12;
SET @varNULL = NULL ;
SET @varString = "Hello";
SET @varJSON = 1; #todo

SELECT @varInt, @varDec, @varFloa, @varNULL, @varString, @varJSON;

USE transactionsample;
drop temporary table if exists foo;
create temporary table foo select @varJSON; 
desc foo;