require 'actn/db/mod'

module Actn
  module Jobs
    class Job < DB::Mod

      self.table = "jobs"
      self.schema = "core" 
      
      data_attr_accessor :hook, :table_name, :record, :record_uuid, :result
      
      validates_presence_of :hook, :table_name
      
    end
  end
end