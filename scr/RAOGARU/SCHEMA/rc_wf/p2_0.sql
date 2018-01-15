--
-- p2 : process definition
--

set autocommit off

-- ######################################################################

PROMPT Make process definition

INSERT INTO WF_PROCESSES ( ID, NAME, DESCRIPTION, CREATION_DATE, VERSION, AUTHOR) VALUES ( 
100, 'ACCESS REQUEST', 'Access Request' , sysdate, '1.0', 'Raogaru');

-- ######################################################################

PROMPT Add activities

INSERT INTO "RC_WF"."WF_ACTIVITIES" 
(PRCE_ID, ID, NAME, DESCRIPTION, START_MODE, FINISH_MODE, IMPLEMENTATION, PATI_QUERY, ASSIGN_TO) 
VALUES 
('100', '10', 'Create ', 'Create', 'MANUAL', 'MANUAL', 'NO', '10', NULL);

INSERT INTO "RC_WF"."WF_ACTIVITIES" 
(PRCE_ID, ID, NAME, DESCRIPTION, SPLIT, START_MODE, FINISH_MODE, IMPLEMENTATION, PATI_QUERY, ASSIGN_TO) VALUES 
('100', '15', 'Submit or Delete', 'Submit or Delete', 'XOR', 'MANUAL', 'MANUAL', 'NO', '10', 
'select pati_id from wf_performers where state=''CURRENT'' and acin_id=(select id from wf_activity_instances where acti_prce_id=100 and acti_id=10 and prin_id=:prin_id_in)');

INSERT INTO "RC_WF"."WF_ACTIVITIES" 
(PRCE_ID, ID, NAME, DESCRIPTION, START_MODE, FINISH_MODE, IMPLEMENTATION, PATI_QUERY) VALUES 
('100', '20', 'TechLead Review', 'TechLead Review', 'MANUAL', 'MANUAL', 'NO', '20');

INSERT INTO "RC_WF"."WF_ACTIVITIES" 
(PRCE_ID, ID, NAME, DESCRIPTION, SPLIT, START_MODE, FINISH_MODE, IMPLEMENTATION, PATI_QUERY) VALUES 
('100', '25', 'TechLead Approval', 'TechLead Approval', 'XOR', 'MANUAL', 'MANUAL', 'NO','20');

-- ######################################################################

PROMPT Add attributes

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('101', '100', 'CHARACTER', 'SUBMITTED', '1', 'Submitted Flag', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('102', '100', 'CHARACTER', 'TECHLEAD_REVIEWED', '1', 'Reviewed by Tech Lead', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('103', '100', 'CHARACTER', 'TECHLEAD_APPROVED', '1', 'Approved by Tech Lead', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('104', '100', 'CHARACTER', 'PROGLEAD_REVIEWED', '1', 'Reviewed by Program Lead', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('105', '100', 'CHARACTER', 'PROGLEAD_APPROVED', '1', 'Approved by Program Lead', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('106', '100', 'CHARACTER', 'MANAGER_REVIEWED', '1', 'Reviewed by Manager', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('107', '100', 'CHARACTER', 'MANAGER_APPROVED', '1', 'Approved by Manager', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('108', '100', 'CHARACTER', 'ENGINEER_REVIEWED', '1', 'Reviewed by Engineer', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('109', '100', 'CHARACTER', 'ENGINEER_APPROVED', '1', 'Approved by Engineer', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('110', '100', 'CHARACTER', 'ENGINEER_PROCESSED', '1', 'Processed by Engineer', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('111', '100', 'CHARACTER', 'REQUEST_CLOSED', '1', 'Request Closed', 'Y');

INSERT INTO "RC_WF"."WF_ATTRIBUTES" (ID, PRCE_ID, DATA_TYPE, NAME, LENGTH, DESCRIPTION, KEEP) 
VALUES ('112', '100', 'INTEGER', 'EMPNO', '10', 'Link to EMP.EMPNO', 'Y');

commit;

-- ######################################################################

PROMPT Add Transitions

INSERT INTO "RC_WF"."WF_TRANSITIONS" 
(ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE) 
VALUES ('100', '10', '100', '15', 'Draft for self review', 'Draft for self review', 'a.name=''SUBMITTED'' AND i.value<>''Y''', 'CONDITION');

INSERT INTO "RC_WF"."WF_TRANSITIONS" 
(ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE) 
VALUES ('100', '15', '100', '20', 'Submit OR Delete', 'Submit for TechLead Review OR Delete request', 'a.name=''SUBMITTED'' AND i.value=''Y''', 'CONDITION');

INSERT INTO "RC_WF"."WF_TRANSITIONS" 
(ACTI_PRCE_ID_FROM, ACTI_ID_FROM, ACTI_PRCE_ID_TO, ACTI_ID_TO, NAME, DESCRIPTION, CONDITION, CONDITION_TYPE) 
VALUES ('100', '20', '100', '25', 'TechLead Review', 'TechLead Review', 'a.name=''TECHLEAD_REVIEWED'' AND i.value=''Y''', 'CONDITION');


commit;

-- ######################################################################
 
