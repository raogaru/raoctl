--------------------------------------------------------
--  File created - Sunday-April-23-2017   
--------------------------------------------------------
REM INSERTING into RC_WF.DEPT
SET DEFINE OFF;
Insert into RC_WF.DEPT (DEPTNO,DNAME,LOC) values (10,'ACCOUNTING','NEW YORK');
Insert into RC_WF.DEPT (DEPTNO,DNAME,LOC) values (20,'RESEARCH','DALLAS');
Insert into RC_WF.DEPT (DEPTNO,DNAME,LOC) values (30,'SALES','CHICAGO');
Insert into RC_WF.DEPT (DEPTNO,DNAME,LOC) values (40,'OPERATIONS','BOSTON');
REM INSERTING into RC_WF.EMP
SET DEFINE OFF;
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7839,'KING','PRESIDENT',null,to_date('17-NOV-81','DD-MON-RR'),5000,null,10);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7698,'BLAKE','MANAGER',7839,to_date('01-MAY-81','DD-MON-RR'),2850,null,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7782,'CLARK','MANAGER',7839,to_date('09-JUN-81','DD-MON-RR'),2450,null,10);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7566,'JONES','MANAGER',7839,to_date('02-APR-81','DD-MON-RR'),2975,null,20);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7788,'SCOTT','ANALYST',7566,to_date('19-APR-87','DD-MON-RR'),3000,null,20);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7902,'FORD','ANALYST',7566,to_date('03-DEC-81','DD-MON-RR'),3000,null,20);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7369,'SMITH','CLERK',7902,to_date('17-DEC-80','DD-MON-RR'),800,null,20);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7499,'ALLEN','SALESMAN',7698,to_date('20-FEB-81','DD-MON-RR'),1600,300,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7521,'WARD','SALESMAN',7698,to_date('22-FEB-81','DD-MON-RR'),1250,500,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7654,'MARTIN','SALESMAN',7698,to_date('28-SEP-81','DD-MON-RR'),1250,1400,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7844,'TURNER','SALESMAN',7698,to_date('08-SEP-81','DD-MON-RR'),1500,0,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7876,'ADAMS','CLERK',7788,to_date('23-MAY-87','DD-MON-RR'),1100,null,20);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7900,'JAMES','CLERK',7698,to_date('03-DEC-81','DD-MON-RR'),950,null,30);
Insert into RC_WF.EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO) values (7934,'MILLER','CLERK',7782,to_date('23-JAN-82','DD-MON-RR'),1300,null,10);
REM INSERTING into RC_WF.WF_ACTIVITIES
SET DEFINE OFF;
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,10,null,null,null,null,'File request to manager','File request to manager',null,null,'MANUAL','MANUAL','NO',null,null,null,'10',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,20,null,null,null,null,'Decide on bonus request','Decide on bonus request',null,'XOR','MANUAL','MANUAL','NO',null,null,null,'20',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,30,null,null,null,null,'Read bonus request denial','Read bonus request denial',null,'XOR','MANUAL','MANUAL','NO',null,null,null,'10',null,'select pati_id
 from wf_performers
 where state = ''CURRENT''
   and acin_id =
 (select id
   from  wf_activity_instances
  where acti_prce_id=10
    and acti_id=10
    and prin_id = :prin_id_in)
',null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,40,null,null,null,null,'File bonus request to president','File bonus request to president',null,null,'MANUAL','MANUAL','NO',null,null,null,'10',null,'select pati_id
 from wf_performers
 where state = ''CURRENT''
   and acin_id =
 (select id
   from  wf_activity_instances
  where acti_prce_id=10
    and acti_id=10
    and prin_id = :prin_id_in)
',null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,50,null,null,null,null,'Final decision on bonus request','Final decision on bonus request','XOR','AND','MANUAL','MANUAL','NO',null,null,null,'7839',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,60,null,null,null,null,'Read request result','Read request result',null,null,'MANUAL','MANUAL','NO',null,null,null,'10',null,'select pati_id
 from wf_performers
 where state = ''CURRENT''
   and acin_id =
 (select id
   from  wf_activity_instances
  where acti_prce_id=10
    and acti_id=10
    and prin_id = :prin_id_in)
',null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (10,70,null,null,null,null,'Add bonus to paycheck','Add bonus to paycheck',null,null,'MANUAL','MANUAL','NO',null,null,null,'40',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (100,20,null,null,null,null,'TechLead Review','TechLead Review',null,null,'MANUAL','MANUAL','NO',null,null,null,'20',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (100,10,null,null,null,null,'Create','Create',null,null,'MANUAL','MANUAL','NO',null,null,null,'10',null,null,null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (100,15,null,null,null,null,'Submit or Delete','Submit or Delete',null,'XOR','MANUAL','MANUAL','NO',null,null,null,'10',null,'select pati_id
 from wf_performers
 where state = ''CURRENT''
   and acin_id =
 (select id
   from  wf_activity_instances
  where acti_prce_id=100
    and acti_id=10
    and prin_id = :prin_id_in)',null,null,null,null,null);
Insert into RC_WF.WF_ACTIVITIES (PRCE_ID,ID,PRCE_ID_HAS_SUBFLOW,APLI_ID,ACTI_PRCE_ID_JOIN_OF,ACTI_ID_JOIN_OF,NAME,DESCRIPTION,JOIN,SPLIT,START_MODE,FINISH_MODE,IMPLEMENTATION,SUBFLOW_EXECUTION,LIMIT,PRIORITY,PATI_QUERY,PATI_EXCLUDE_QUERY,ASSIGN_TO,READ_ACCESS,WRITE_ACCESS,CREATE_DELAY_EXPR,WORKLIST_DISPLAY_QUERY,REPLICATION_TIMESTAMP) values (100,25,null,null,null,null,'TechLead Approval','TechLead Approval',null,'XOR','MANUAL','MANUAL','NO',null,null,null,'20',null,null,null,null,null,null,null);
REM INSERTING into RC_WF.WF_ACTIVITY_ATTRIBUTES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ACTIVITY_INSTANCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ACTIVITY_INSTANCES_ARCH
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ACTI_ATTRIBUTE_INSTANCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ACTI_ATTRIB_INSTANCES_ARCH
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ACTUAL_PARAMETERS
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_APPLICATIONS
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ATTRIBUTES
SET DEFINE OFF;
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (10,10,'INTEGER','EMPNO',10,'Link to EMP.EMPNO',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (20,10,'CHARACTER','APPROVED',1,'Is the request approved',null,'N',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (30,10,'CHARACTER','HAPPY',1,'Is the employee happy with the result?',null,'N',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (101,100,'CHARACTER','SUBMITTED',1,'Submitted Flag','N','Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (102,100,'CHARACTER','TECHLEAD_REVIEWED',1,'Reviewed by Tech Lead',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (103,100,'CHARACTER','TECHLEAD_APPROVED',1,'Approved by Tech Lead',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (104,100,'CHARACTER','PROGLEAD_REVIEWED',1,'Reviewed by Program Lead',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (105,100,'CHARACTER','PROGLEAD_APPROVED',1,'Approved by Program Lead',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (106,100,'CHARACTER','MANAGER_REVIEWED',1,'Reviewed by Manager',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (107,100,'CHARACTER','MANAGER_APPROVED',1,'Approved by Manager',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (108,100,'CHARACTER','ENGINEER_REVIEWED',1,'Reviewed by Engineer',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (109,100,'CHARACTER','ENGINEER_APPROVED',1,'Approved by Engineer',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (110,100,'CHARACTER','ENGINEER_PROCESSED',1,'Processed by Engineer',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (111,100,'CHARACTER','REQUEST_CLOSED',1,'Request Closed',null,'Y',null);
Insert into RC_WF.WF_ATTRIBUTES (ID,PRCE_ID,DATA_TYPE,NAME,LENGTH,DESCRIPTION,INITIAL_VALUE,KEEP,REPLICATION_TIMESTAMP) values (112,100,'INTEGER','EMPNO',10,'Link to EMP.EMPNO',null,'Y',null);
REM INSERTING into RC_WF.WF_ATTRIBUTE_INSTANCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_ATTRIBUTE_INSTANCES_ARCH
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_DEADLINES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_DEBUG_LOG
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_EXTERNAL_REFERENCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_FORMAL_PARAMETERS
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_PARTICIPANTS
SET DEFINE OFF;
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (10,'EMPLOYEE','The employee role','ROLE',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (20,'MANAGER','The manager role','ROLE',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (30,'PRESIDENT','The president role','ROLE',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (40,'ACCOUNTING','The accounting role','ROLE',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (50,'TEST_GRANT_TRANSITIVITY','Role to test transitivity of grants','ROLE',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7839,'KING','PRESIDENT','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7698,'BLAKE','MANAGER','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7782,'CLARK','MANAGER','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7566,'JONES','MANAGER','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7788,'SCOTT','ANALYST','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7902,'FORD','ANALYST','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7369,'SMITH','CLERK','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7499,'ALLEN','SALESMAN','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7521,'WARD','SALESMAN','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7654,'MARTIN','SALESMAN','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7844,'TURNER','SALESMAN','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7876,'ADAMS','CLERK','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7900,'JAMES','CLERK','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (7934,'MILLER','CLERK','HUMAN',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (60,'ACCOUNTING','The accounting department','ORGANIZATIONAL_UNIT',null,null);
Insert into RC_WF.WF_PARTICIPANTS (ID,NAME,DESCRIPTION,PARTICIPANT_TYPE,STATE,REPLICATION_TIMESTAMP) values (1,'PL/FLOW','The workflow engine itself','SYSTEM',null,null);
REM INSERTING into RC_WF.WF_PARTICIPANT_RELATIONS
SET DEFINE OFF;
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7698,20,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7782,20,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7566,20,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7839,30,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7839,60,'MEMBER OF',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7782,60,'MEMBER OF',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7934,60,'MEMBER OF',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (50,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (50,20,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (50,30,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (50,40,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7788,50,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (60,40,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7369,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7499,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7521,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7566,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7654,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7698,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7782,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7788,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7839,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7844,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7876,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7900,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7902,10,'GRANT',null);
Insert into RC_WF.WF_PARTICIPANT_RELATIONS (PATI_ID_ARG1,PATI_ID_ARG2,RELATION_TYPE,REPLICATION_TIMESTAMP) values (7934,10,'GRANT',null);
REM INSERTING into RC_WF.WF_PERFORMERS
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_PERFORMERS_ARCH
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_PROCESSES
SET DEFINE OFF;
Insert into RC_WF.WF_PROCESSES (ID,NAME,DESCRIPTION,CREATION_DATE,VERSION,AUTHOR,DURATION,LIMIT,VALID_FROM,VALID_TO,WAITING_TIME,WORKING_TIME,REPLICATION_TIMESTAMP) values (10,'FILE BONUS REQUEST','The process of filing a request for a bonus by an employee.',null,null,null,null,null,null,null,null,null,null);
Insert into RC_WF.WF_PROCESSES (ID,NAME,DESCRIPTION,CREATION_DATE,VERSION,AUTHOR,DURATION,LIMIT,VALID_FROM,VALID_TO,WAITING_TIME,WORKING_TIME,REPLICATION_TIMESTAMP) values (100,'ACCESS REQUEST','Access Request',to_date('22-APR-17','DD-MON-RR'),'1.0','Raogaru',null,null,null,null,null,null,null);
REM INSERTING into RC_WF.WF_PROCESS_INSTANCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_PROCESS_INSTANCES_ARCH
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_TRANSITIONS
SET DEFINE OFF;
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,10,10,20,'request to manager','request to manager',null,null,null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,20,10,30,'denied by manager','denied by manager','a.name=''APPROVED'' AND i.value <>''Y''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,20,10,50,'approved by manager','approved by manager','a.name=''APPROVED'' AND i.value =''Y''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,30,10,40,'not happe','employee is not happy','a.name=''HAPPY'' and i.value=''N''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,40,10,50,'request to president','request to president',null,null,null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,50,10,60,'result to employee','final result to employee',null,null,null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (10,50,10,70,'change paycheck','change paycheck','a.name=''APPROVED'' and i.value=''Y''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (100,10,100,15,'Draft for self review','Draft for self review','a.name=''SUBMITTED'' AND i.value=''N''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (100,15,100,20,'Submit OR Delete','Submit for TechLead Review OR Delete request','a.name=''SUBMITTED'' AND i.value=''Y''','CONDITION',null);
Insert into RC_WF.WF_TRANSITIONS (ACTI_PRCE_ID_FROM,ACTI_ID_FROM,ACTI_PRCE_ID_TO,ACTI_ID_TO,NAME,DESCRIPTION,CONDITION,CONDITION_TYPE,REPLICATION_TIMESTAMP) values (100,20,100,25,'TechLead Review','TechLead Review','a.name=''TECHLEAD_REVIEWED'' AND i.value=''Y''','CONDITION',null);
REM INSERTING into RC_WF.WF_TRANSITION_INSTANCES
SET DEFINE OFF;
REM INSERTING into RC_WF.WF_TRANSITION_INSTANCES_ARCH
SET DEFINE OFF;