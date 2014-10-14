SET search_path TO public;

SELECT plv8_startup();

SELECT __create_table('core','jobs');



CREATE or REPLACE FUNCTION model_trigger() RETURNS trigger AS $$
  actn.jobs.model_trigger(TG_TABLE_NAME, TG_OP, NEW, OLD);
$$ LANGUAGE plv8 STABLE STRICT;



CREATE or REPLACE FUNCTION jobs_model_callbacks() RETURNS trigger AS $$
  actn.jobs.jobs_model_callbacks(TG_TABLE_NAME, TG_OP, NEW, OLD)
$$ LANGUAGE plv8 STABLE STRICT;



CREATE TRIGGER jobs_core_models_callback_trigger 
AFTER INSERT OR UPDATE OR DELETE ON core.models
FOR EACH ROW EXECUTE PROCEDURE jobs_model_callbacks();