-- TITLE1:Ruleset Aggregate Statistics
-- TITLE2: Displaying Aggregate Statistics for All Rule Set Evaluations
-- DESC: You can query the V$RULE_SET_AGGREGATE_STATS dynamic performance view to display statistics for all rule set evaluations since the database instance last started.

COLUMN NAME HEADING 'Name of Statistic' FORMAT A55
COLUMN VALUE HEADING 'Value' FORMAT 999999999

SELECT NAME, VALUE FROM V$RULE_SET_AGGREGATE_STATS;
