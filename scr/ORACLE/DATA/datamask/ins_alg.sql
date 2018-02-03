delete from data_mask_alg;

insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_ALL','Social Security Number Hash All Digits');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_HASH_LAST_6','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_STAR_LAST_6','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'SSN','SSN_MASK_LAST_6','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_6','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_HASH_LAST_8','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_6','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_STAR_LAST_8','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_6','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_VISA_MASK_LAST_8','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_8','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_HASH_LAST_11','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_8','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_STAR_LAST_11','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_5','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_8','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'CREDITCARD','CC_AMEX_MASK_LAST_11','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_HASH_LAST_7','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_STAR_LAST_7','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_ALL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_LAST_4','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'PHONE','PHONE_MASK_LAST_7','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_NULL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_FIXED_SIZE','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','CLOB_VARIABLE_SIZE','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_NULL','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_RANDOM_FIXED_SIZE','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'LOB','BLOB_RANDOM_VARIABLE_SIZE','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_RANDOM','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_FIXED','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_PAST','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_FUTURE','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_DD','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_MM','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'DATE','DATE_ADD_YY','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_RANDOM','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_FIXED','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_HH','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_HH','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_MI','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_MI','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_PLUS_SS','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'TIME','TIME_MINUS_SS','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_STRING','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_PREFIX','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_FIXED_SUFFIX','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_UPPER','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_LOWER','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHA_MIXED','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_ALPHANUM_MIXED','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'STRING','STR_RANDOM_PRINTABLE_CHAR','XXX');
--
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_FIXED','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_ADD','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_SUBSTRACT','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_MULTIPLY','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_DIVIDE','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_RANDOM_INTEGER','XXX');
insert into data_mask_alg values (data_mask_seq.nextval,'NUMBER','NUM_RANDOM_INTEGER_BETWEEN','XXX');
--
commit;
