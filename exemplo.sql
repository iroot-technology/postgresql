CREATE OR REPLACE FUNCTION pivotcode_sql(
    tablename character varying,
    rowc character varying,
    colc character varying,
    cellc character varying,
    celldatatype character varying)
    RETURNS json
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

declare
    dynsql1 varchar;
    dynsql2 varchar;
    columnlist varchar;
    result json;
begin
    -- 1. retrieve list of column names.
    dynsql1 = 'select string_agg(distinct ''"''||'||colc||'||''" '||celldatatype||''','','' order by ''"''||'||colc||'||''" '||celldatatype||''') from '||tablename||';';
    execute dynsql1 into columnlist;
    -- 2. set up the crosstab query
    --tablename = REPLACE(text, ''', E'\\"')
    dynsql2 = 'select array_to_json(array_agg(row_to_json(foo))) from (select * from crosstab (
 ''select '||rowc||','||colc||','||cellc||' from '||replace(tablename, chr(39),E'\'\'')||' group by 1,2 order by 1,2'',
 ''select distinct '||colc||' from '||replace(tablename, chr(39),E'\'\'')||' order by 1''
 )
 as newtable (
 '||rowc||' varchar,'||columnlist||'
 )) foo;';
    execute dynsql2 into result;
    return result;
end
$BODY$;


select pivotcode_sql('precos', 'id_produto', 'id_preco', 'sum(valor)', 'numeric(10,2)');
