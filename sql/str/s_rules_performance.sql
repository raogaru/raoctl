-- Complex rules could result in performance issues. Avoid 'not in' and '!=' in the rule definitions.
-- Capture 
select capture_name, owner, name from gv$rule_set r, dba_capture c 
where c.rule_set_owner = r.owner and c.rule_set_name = r.name 
and r.sql_executions > 0; 

-- Propagation
select propagation_name, owner, name from gv$rule_set r, dba_propagation p where p.rule_set_owner = r.owner and p.rule_set_name = r.name 
and r.sql_executions > 0; 

-- Apply
select apply_name, owner, name from gv$rule_set r, dba_apply a 
where a.rule_set_owner = r.owner and a.rule_set_name = r.name 
and r.sql_executions > 0;
