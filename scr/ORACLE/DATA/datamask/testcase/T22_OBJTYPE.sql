--
-- DATA MASK test case table 
--

-- OBJECT specification
CREATE OR REPLACE TYPE PersonObj AS OBJECT (
  emp_typ CHAR(1),
  emp_name VARCHAR2(30),
  emp_id   NUMBER,
  emp_hired DATE,
  emp_login TIMESTAMP,
  MEMBER FUNCTION getExperience RETURN NUMBER,
  MEMBER FUNCTION getType RETURN CHAR,
  MEMBER FUNCTION getName RETURN VARCHAR2 ,
  MEMBER FUNCTION getID RETURN NUMBER ,
  MEMBER FUNCTION getHired RETURN DATE ,
  MEMBER FUNCTION getLogin RETURN TIMESTAMP 
);
/

-- OBJECT BODY with member functions
CREATE OR REPLACE TYPE BODY PersonObj AS
  MEMBER FUNCTION getExperience RETURN NUMBER AS
  BEGIN
    RETURN Trunc(Months_Between(Sysdate, emp_hired)/12);
  END ;
  --
  MEMBER FUNCTION getType RETURN CHAR AS
  BEGIN
    RETURN emp_typ;
  END ;
  --
  MEMBER FUNCTION getName RETURN VARCHAR2 AS
  BEGIN
    RETURN emp_name;
  END ;
  --
  MEMBER FUNCTION getID RETURN NUMBER AS
  BEGIN
    RETURN emp_id;
  END ;
  --
  MEMBER FUNCTION getHired RETURN DATE AS
  BEGIN
    RETURN emp_hired;
  END ;
  --
  MEMBER FUNCTION getLogin RETURN TIMESTAMP AS
  BEGIN
    RETURN emp_login;
  END ;
  --
END;
/

drop table T22_OBJTYPE ;

create table T22_OBJTYPE (
id number,
o PersonObj
);

-- insert rows
insert /*+ append no logging */ 
into T22_OBJTYPE  (id,o)
with a as (select level  from dual connect by level <=1000)
select rownum, 
PersonObj('E'
,dbms_random.string('A',10)
,round(dbms_random.value(1000,100000),0)
,trunc(sysdate+dbms_random.value(0,366))
,systimestamp+dbms_random.value(0,366))
from a a1, a a2
where rownum<500;
commit;

-- select using object attributes
select a.id, a.o.emp_id, a.o.emp_typ, a.o.emp_name, a.o.emp_hired, a.o.emp_login from T22_OBJTYPE a order by id;

-- select using member functions
select a.id, a.o.getID(), a.o.GetType(), a.o.getName(), a.o.getHired(), a.o.getLogin() from T22_OBJTYPE a order by id;

--
--
