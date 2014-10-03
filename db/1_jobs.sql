SET search_path TO public;

SELECT plv8_startup();

SELECT __create_table('core','jobs');

CREATE or REPLACE FUNCTION hook_trigger() RETURNS trigger AS
$$
    upsert_func = plv8.find_function("__upsert")
    model = JSON.parse(plv8.find_function("__find_model")(TG_TABLE_NAME.classify()))

    callback  = {
      INSERT: "after_create"     
      UPDATE: "after_update"
      DELETE: "after_destroy"
    }[TG_OP]  
    
    # plv8.elog(NOTICE,"HOOK TRIGGER",JSON.stringify(model))
    
    for hook in model?.hooks?[callback] or []
      hook.run_at ?= new Date()
      hook.callback = callback
      
      job = 
        hook: hook
        table_name: TG_TABLE_NAME
        record_uuid: NEW?.data?.uuid or OLD?.data?.uuid  
        record: OLD.data if TG_OP is "DELETE"
      
      res = upsert_func "core", "jobs", JSON.stringify(job)
      plv8.execute "SELECT pg_notify('jobs', $1);", [res]

    
$$ LANGUAGE plcoffee STABLE STRICT;






CREATE or REPLACE FUNCTION jobs_model_callbacks() RETURNS trigger AS
$$
  table_name = (NEW?.data?.name or OLD?.data?.name).tableize()
  
  table_schema = (NEW?.data?.table_schema or OLD?.data?.table_schema) or "public"

  return if table_schema is "core"
  
  if TG_OP is "DELETE"
    plv8.execute "DELETE FROM core.jobs WHERE __string(data, 'table_name'::text) = $1;", [table_name]

  # if TG_OP is "DELETE" and OLD.data.hooks? or TG_OP is "UPDATE" and NEW.data.hooks?
  #   plv8.execute "DROP TRIGGER IF EXISTS #{table_schema}_#{table_name}_hook_trigger ON #{table_schema}.#{table_name}"

    
  if TG_OP is "INSERT" or TG_OP is "UPDATE" and NEW.data.hooks? and not OLD.data.hooks?
    plv8.execute """CREATE TRIGGER #{table_schema}_#{table_name}_hook_trigger 
                  AFTER INSERT OR UPDATE OR DELETE ON #{table_schema}.#{table_name} 
                  FOR EACH ROW EXECUTE PROCEDURE hook_trigger();"""
                    

    
$$ LANGUAGE plcoffee STABLE STRICT;

CREATE TRIGGER jobs_core_models_callback_trigger 
AFTER INSERT OR UPDATE OR DELETE ON core.models
FOR EACH ROW EXECUTE PROCEDURE jobs_model_callbacks();