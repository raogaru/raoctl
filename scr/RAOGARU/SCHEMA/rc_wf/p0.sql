-- SQL script to create the example process definition
-- Assumed to run in SCOTT's schema or in a schema that can read SCOTT's tables
-- 2003 11 25 Yeb Havinga

Prompt Insert ROLES
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 10, 'EMPLOYEE', 'The employee role', 'ROLE' )
/          
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 20, 'MANAGER', 'The manager role', 'ROLE' )
/
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 30, 'PRESIDENT', 'The president role', 'ROLE' )
/
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 40, 'ACCOUNTING', 'The accounting role', 'ROLE' )
/
-- this role is only to test transitivity of grants (grants from role to role)
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 50, 'TEST_GRANT_TRANSITIVITY', 'Role to test transitivity of grants', 'ROLE' )
/
Prompt Make participants for the employees

INSERT INTO wf_participants
          ( id, name, description, participant_type )
     SELECT empno, ename, job, 'HUMAN'
       FROM emp
/
Prompt Grant 'EMPLOYEE' role to all employees
   
INSERT INTO wf_participant_relations ( pati_id_arg1, pati_id_arg2, relation_type )
     SELECT id, 10, 'GRANT'   -- 10 is id of participant role EMPLOYEE
	   FROM wf_participants
      WHERE id IN (SELECT empno FROM emp) -- only the emps
/
Prompt Grant 'MANAGER' role to the managers 
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     SELECT id, 20, 'GRANT'   -- 20 is id of participant role MANAGER
	   FROM wf_participants
      WHERE id IN (SELECT empno
	                 FROM emp
					WHERE job='MANAGER') -- only the managers
/ 
Prompt Grant 'PRESIDENT' role to the presidents
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     SELECT id, 30, 'GRANT'   -- 30 is id of participant role PRESIDENT
	   FROM wf_participants
      WHERE id IN (SELECT empno
	                 FROM emp
					WHERE job='PRESIDENT')
/
Prompt Grant every other role to the 'TEST_GRANT_TRANSITIVITY' role
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     SELECT 50, id, 'GRANT'   -- 30 is id of participant role PRESIDENT
	   FROM wf_participants
      WHERE id <> 50
        AND participant_type='ROLE'
/
Prompt Grant SCOTT the test grant transitivity role
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     VALUES ( 7788, 50,  'GRANT'  )
/

Prompt Create the accounting organization
INSERT INTO wf_participants
          ( id, name, description, participant_type )
     VALUES
          ( 60, 'ACCOUNTING', 'The accounting department', 'ORGANIZATIONAL_UNIT' )
/
Prompt Grant 'ACCOUNTING' role to the organization ACCOUNTING 
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     VALUES ( 60, 40, 'GRANT' )   -- id 40 is role 'accounting'
/
Prompt Make emps MEMBER OF the accounting department.
INSERT INTO wf_participant_relations
          ( pati_id_arg1, pati_id_arg2, relation_type )
     SELECT id, 60, 'MEMBER OF'
	   FROM wf_participants
      WHERE id IN (SELECT empno -- the id's from accounting emps
	                 FROM emp
					WHERE deptno=
					    (SELECT deptno -- get id from accounting
					       FROM dept
					      WHERE dname='ACCOUNTING'))

/
