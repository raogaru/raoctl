break on acti_prce_id on prin_id skip 1 
set linesi 1000 trims on pagesi 1000 head on
col name format a32
prompt ##### Activity Status
SELECT a.acti_prce_id, a.prin_id, a.acti_id, b.name, a.id, a.state, a.date_created, a.date_started, a.date_ended
FROM WF_ACTIVITY_INSTANCES a, wf_activities b
where a.acti_id=b.id
and a.acti_prce_id=10
and a.acti_prce_id=b.prce_id
order by acti_prce_id, prin_id, acti_id;

prompt ##### Performer Status
SELECT a.id, a.pati_id, b.name||'('||b.description||')' name, a.acin_id, a.date_created, a.state, a.accepted 
FROM WF_PERFORMERS a, wf_participants b
where a.pati_id=b.id;
