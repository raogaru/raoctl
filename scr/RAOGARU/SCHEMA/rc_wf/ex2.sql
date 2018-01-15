-- Example 2. Continues from example 1

SPOOL example2.lst
 
INSERT INTO WF_PROCESSES ( ID, NAME, DESCRIPTION, CREATION_DATE, VERSION, AUTHOR ) VALUES ( 
20, 'Example process 20', 'Example process 20 for testing subflow call and start activity with incoming transition'
,  TO_Date( '12/08/2003 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'), '1', 'yepster'); 
INSERT INTO WF_PROCESSES ( ID, NAME, DESCRIPTION, CREATION_DATE, VERSION, AUTHOR ) VALUES ( 
30, 'Example process 30', 'Example process 30 is to be called as subflow by process 20'
,  TO_Date( '12/08/2003 12:00:00 AM', 'MM/DD/YYYY HH:MI:SS AM'), '1', 'yepster'); 
 
INSERT INTO WF_ATTRIBUTES ( ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP
 ) VALUES ( 
40, 20, 'CHARACTER', 'LOOP?', 1, 'Loop?', 'Y'); 
INSERT INTO WF_ATTRIBUTES ( ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, INITIAL_VALUE
, KEEP ) VALUES ( 
50, 30, 'CHARACTER', 'RESULTCODE', 1, 'Resultcode. Y means loop the parent process'
, 'Y', 'N'); 
 
 
INSERT INTO WF_APPLICATIONS ( ID, NAME, DESCRIPTION, PLSQL_PROC_NAME ) VALUES ( 
10, 'Send warning mail', 'Send a warning mail', 'SEND_WARNING_MAIL'); 
INSERT INTO WF_FORMAL_PARAMETERS ( ID, PRCE_ID, APLI_ID, DATA_TYPE, FOPA_MODE, NAME, DESCRIPTION
 ) VALUES ( 
1001, NULL, 10, 'INTEGER', 'IN', 'ACIN_ID_IN', 'Activity instance id'); 

INSERT INTO WF_APPLICATIONS ( ID, NAME, DESCRIPTION, PLSQL_PROC_NAME ) VALUES ( 
20, 'Send notification of termination', 'Send notification of termination of process 30'
, 'SEND_TERMINATION_NOTIFICATION'); 
INSERT INTO WF_FORMAL_PARAMETERS ( ID, PRCE_ID, APLI_ID, DATA_TYPE, FOPA_MODE, NAME, DESCRIPTION
 ) VALUES ( 
2001, NULL, 20, 'INTEGER', 'IN', 'ACIN_ID_IN', 'Activity instance id'); 

INSERT INTO WF_ACTIVITIES ( PRCE_ID, ID, PRCE_ID_HAS_SUBFLOW, PATI_query, NAME, DESCRIPTION
, create_delay_expr, START_MODE, FINISH_MODE, IMPLEMENTATION, SUBFLOW_EXECUTION ) VALUES ( 
20, 10, 30, 40, 'Test start activity with incoming transition', 'Test start activity with incoming transition'
, NULL, 'AUTOMATIC', 'AUTOMATIC', 'SUBFLOW', 'SYNCHR'); 
INSERT INTO WF_ACTIVITIES ( PRCE_ID, ID, PATI_query, NAME, DESCRIPTION, create_delay_expr
, START_MODE, FINISH_MODE, IMPLEMENTATION ) VALUES ( 
30, 10, 40, 'Dummy Activity', 'The first dummy activity. With a deadline', NULL, 'MANUAL'
, 'MANUAL', 'NO'); 

INSERT INTO WF_ACTIVITIES ( PRCE_ID, ID, APLI_ID, PATI_query, NAME, DESCRIPTION, create_delay_expr
, START_MODE, FINISH_MODE, IMPLEMENTATION ) VALUES ( 
30, 20, 10, 1, 'Application 10: send a warning mail', 'Application 10: send a warning mail'
, NULL, 'AUTOMATIC', 'AUTOMATIC', 'TOOL'); 
INSERT INTO WF_ACTUAL_PARAMETERS ( ID, ACTI_PRCE_ID, ACTI_ID, FOPA_ID, EXPRESSION, ATRI_ID ) VALUES ( 
302001, 30, 20, 1001, 'acin.id', NULL);

INSERT INTO WF_ACTIVITIES ( PRCE_ID, ID, APLI_ID, PATI_query, NAME, DESCRIPTION, create_delay_expr
, START_MODE, FINISH_MODE, IMPLEMENTATION ) VALUES ( 
30, 30, 20, 1, 'Application 20: send termination notification', 'Application 20: send termination notification'
, NULL, 'AUTOMATIC', 'AUTOMATIC', 'TOOL'); 
INSERT INTO WF_ACTUAL_PARAMETERS ( ID, ACTI_PRCE_ID, ACTI_ID, FOPA_ID, EXPRESSION, ATRI_ID ) VALUES ( 
303001, 30, 30, 2001, 'acin.id', NULL);
 
-- Name or index are not necessary.. out parm is linked on fopa_id to the correct
-- actual parameter, which is linked on atri_id to the right parent process attribute. (pfff)
INSERT INTO WF_FORMAL_PARAMETERS ( ID, PRCE_ID, ATRI_ID, DATA_TYPE, FOPA_MODE, DESCRIPTION
 ) VALUES ( 
10, 30, 50, 'CHARACTER', 'OUT', 'This process attribute is OUT parameter'); 
 
INSERT INTO WF_ACTUAL_PARAMETERS ( ID, ACTI_PRCE_ID, ACTI_ID, FOPA_ID, ATRI_ID ) VALUES ( 
10, 20, 10, 10, 40); 


INSERT INTO WF_DEADLINES ( ID, ACTI_ID, ACTI_PRCE_ID, EXECUTION, CONDITION, EXCEPTION_NAME
 ) VALUES ( 
20, 10, 30, 'SYNCHR', '1/24/30', 'dummy_activity_timed_out'); 
INSERT INTO WF_DEADLINES ( ID, ACTI_ID, ACTI_PRCE_ID, EXECUTION, CONDITION, EXCEPTION_NAME
 ) VALUES ( 
10, 10, 30, 'ASYNCHR', '1/24/60', 'dummy_activity_time_warning'); 
 
 
INSERT INTO WF_TRANSITIONS ( ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO
, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE ) VALUES ( 
20, 10, 20, 10, 'loop to start activity', 'loop to start activity', 'a.name=''LOOP?'' AND i.value= ''Y'''
, 'CONDITION'); 
INSERT INTO WF_TRANSITIONS ( ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO
, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE ) VALUES ( 
30, 10, 30, 20, 'deadline warning transition', 'deadline warning transition', 'dummy_activity_time_warning'
, 'EXCEPTION'); 
INSERT INTO WF_TRANSITIONS ( ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO
, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE ) VALUES ( 
30, 10, 30, 30, 'deadline timeout transition', 'deadline timeout transition', 'dummy_activity_timed_out'
, 'EXCEPTION'); 
commit;

CREATE OR REPLACE PROCEDURE SEND_WARNING_MAIL(
    acin_id_in IN  wf_activity_instances.id%TYPE
)
IS
    mysmtphost      VARCHAR(100)   DEFAULT 'mysmtphost';       -- change this or put it in /etc/hosts
    mydomain        VARCHAR(100)   DEFAULT 'portavita.nl';          -- for sending mail from
    myemailaddress  VARCHAR(100)   DEFAULT 'plflow@portavita.nl';
    mail_errors_to  VARCHAR(100)   DEFAULT 'yeb.havinga@portavita.nl';     -- email address to mail wf runtime errors to.
BEGIN
-- send mail
    pl_flow.send_mail( smtp_server_in=>mysmtphost,
               domain_in=>mydomain,
               sender_name_in=>'PL/FLOW',
               sender_email_in=>myemailaddress,
               recipient_name_in=>'recipient of wf errors',
               recipient_email_in=>mail_errors_to,
               subject_in=>'Warning: activity 30 10 is overdue.',
               body_in=>'Warning: activity 30 10 is overdue.\n(this workitem: instance ' || acin_id_in || ')');

--?    COMMIT WORK;
-- exception?
EXCEPTION
WHEN OTHERS THEN
    pl_flow.send_mail( smtp_server_in=>mysmtphost,
               domain_in=>mydomain,
               sender_name_in=>'PL/FLOW',
               sender_email_in=>myemailaddress,
               recipient_name_in=>'recipient of wf errors',
               recipient_email_in=>mail_errors_to,
               subject_in=>'Error in SEND_WARNING_MAIL',
               body_in=>'Error: ' || SQLERRM );
               
END SEND_WARNING_MAIL;
/


CREATE OR REPLACE PROCEDURE SEND_TERMINATION_NOTIFICATION(
    acin_id_in  IN wf_activity_instances.id%TYPE
)
IS
    mysmtphost      VARCHAR(100)   DEFAULT 'mysmtphost';       -- change this or put it in /etc/hosts
    mydomain        VARCHAR(100)   DEFAULT 'portavita.nl';          -- for sending mail from
    myemailaddress  VARCHAR(100)   DEFAULT 'plflow@portavita.nl';
    mail_errors_to  VARCHAR(100)   DEFAULT 'yeb.havinga@portavita.nl';     -- email address to mail wf runtime errors to.
BEGIN
-- send mail
    pl_flow.send_mail( smtp_server_in=>mysmtphost,
               domain_in=>mydomain,
               sender_name_in=>'PL/FLOW',
               sender_email_in=>myemailaddress,
               recipient_name_in=>'recipient of wf errors',
               recipient_email_in=>mail_errors_to,
               subject_in=>'Warning: activity 30 10 is timed out.',
               body_in=>'Warning: activity 30 10 is timed out.\n (this workitem: instance ' || acin_id_in || ')');
---?    COMMIT WORK;
-- exception?
EXCEPTION
WHEN OTHERS THEN
    pl_flow.send_mail( smtp_server_in=>mysmtphost,
               domain_in=>mydomain,
               sender_name_in=>'PL/FLOW',
               sender_email_in=>myemailaddress,
               recipient_name_in=>'recipient of wf errors',
               recipient_email_in=>mail_errors_to,
               subject_in=>'Error in SEND_WARNING_MAIL',
               body_in=>'Error: ' || SQLERRM );
               
END SEND_TERMINATION_NOTIFICATION;
/


SPOOL OFF

COMMIT
/
QUIT
/
