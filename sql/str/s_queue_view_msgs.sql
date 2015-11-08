-- TITLE1: View Messages
-- TITLE2: Viewing the Contents of Messages in a Persistent Queue
-- DESC:

SELECT qt.user_data.AccessNumber() "Numbers in Queue" ,
qt.user_data.AccessVarchar2() "Varchar2s in Queue",
  FROM strmadmin.oe_q_table_any qt;
