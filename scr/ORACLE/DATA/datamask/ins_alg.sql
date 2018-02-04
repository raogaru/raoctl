delete from data_mask_alg;

insert into data_mask_alg values (data_mask_seq.nextval,'ALL','FILL_NULL','For any data type');

insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_ALL','Social Security Number Hash All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_4','Social Security Number Hash Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_5','Social Security Number Hash Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_6','Social Security Number Hash Last 6 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_ALL','Social Security Number Star All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_4','Social Security Number Star Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_5','Social Security Number Star Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_6','Social Security Number Star Last 6 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_ALL','Social Security Number Mask All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_4','Social Security Number Mask Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_5','Social Security Number Mask Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_6','Social Security Number Mask Last 6 Digits');
--
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_ALL','VISA Credit Card Hash All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_4','VISA Credit Card Hash Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_6','VISA Credit Card Hash Last 6 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_8','VISA Credit Card Hash Last 8 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_ALL','VISA Credit Card Star All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_4','VISA Credit Card Star Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_6','VISA Credit Card Star Last 6 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_8','VISA Credit Card Star Last 8 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_ALL','VISA Credit Card Mask All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_4','VISA Credit Card Mask Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_6','VISA Credit Card Mask Last 6 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_8','VISA Credit Card Mask Last 8 Digits');
--
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_ALL','AMEX Credit Card Hash All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_5','AMEX Credit Card Hash Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_8','AMEX Credit Card Hash Last 8 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_11','AMEX Credit Card Hash Last 11 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_ALL','AMEX Credit Card Star All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_5','AMEX Credit Card Star Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_8','AMEX Credit Card Star Last 8 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_11','AMEX Credit Card Star Last 11 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_ALL','AMEX Credit Card Mask All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_5','AMEX Credit Card Mask Last 5 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_8','AMEX Credit Card Mask Last 8 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_11','AMEX Credit Card Mask Last 11 Digits');
--
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_ALL','Phone Number Hash All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_LAST_4','Phone Number Hash Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_LAST_7','Phone Number Hash Last 7 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_ALL','Phone Number Star All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_LAST_4','Phone Number Star Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_LAST_7','Phone Number Star Last 7 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_ALL','Phone Number Mask All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_LAST_4','Phone Number Mask Last 4 Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_LAST_7','Phone Number Mask Last 7 Digits');
--
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_NULL','Nullify CLOB');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_FIXED_SIZE','Fixed Size CLOB. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_VARIABLE_SIZE','Variable Size CLOB. val=M,N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_NULL','Nullify BLOB');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_RANDOM_FIXED_SIZE','Fixed Size BLOB. val=M');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_RANDOM_VARIABLE_SIZE','Variable Size BLOB. val=M,N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_RANDOM','Random Date between current date +/- 100 years');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_FIXED','Fixed Date. val=YYYY-MM-DD');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_PAST','Past date. sysdate-1 to sysdate-N. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_FUTURE',Future Date. sysdate+1 to sysdate+N. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_DD','Add Days. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_MM','Add Months. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_YY','Add Years. val=N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_RANDOM','Random Timestamp between current time +/- 100 years');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_FIXED','Fixed Timestamp. val=YYYY-MM-DD HH24.MI.SS.FF');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_HH','Plus Hours. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_HH','Minus Hours. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_MI','Plus Minutes. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_MI','Minus Minutes. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_SS','Plus Seconds. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_SS','Minus Seconds. val=N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_STRING','Fixed String. v=StringWithoutQuotes');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_PREFIX','Add Prefix. val=String');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_SUFFIX','Add Suffix. val=String');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_UPPER','Random Uppercase Albhabets of length between M and N. Specify M=N for CHAR data types. val=M,N');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_LOWER','Random Lowercase Albhabets of length between M and N. Specify M=N for CHAR data types. val=M,N');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_MIXED','Random Mixedcase Albhabets of length between M and N. Specify M=N for CHAR data types. val=M,N');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHANUM_MIXED','Random Uppercase Alpha Numeric Letters of length between M and N. Specify M=N for CHAR data types. val=M,N');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_PRINTABLE_CHAR','Random Printable Characters of length between M and N. Specify M=N for CHAR data types. val=M,N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_FIXED','Fixed Number. N can be any preceision or scale. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_PLUS','Column Value PLUS given number N. N can be any precision/scale. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_MINUS','Column Value MINUS given number N. N can be any precision/scale. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_RANDOM_INTEGER_DIGITS','Random Integer number with N or N-1 digits. val=N');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_RANDOM_INTEGER_BETWEEN','Random Integer number between M and N. val=M,N');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_RANDOM_DECIMAL','Random Decimal number with precision=M and scale=N. val=M,N');
--
insert into data_mask_alg values (data_mask_seq.nextval,'ANYDATA','ANYDATA_TYPE_NULL','Nullify Payloads in SYS.ANYDATA Data type');
insert into data_mask_alg values (data_mask_seq.nextval,'ANYDATA','ANYDATA_TYPE_MASK','Mask Payloads in SYS.ANYDATA data type with corresponding datatype');
--
commit;
