require 'oj'
require 'time'
require 'actn/db/set'

module Actn
  module Jobs
    
    class Base
      attr_accessor :job, :record
      
      def initialize job
        @job = job
        @record = job.record || Oj.load(DB::Set[job.table_name].find_by({uuid: job.record_uuid}))
      end
      
      def perform
      end
      
      def test_and_perform
        
        unless self.record
          $stderr.puts "[#{self.class.name}#test_and_perform, #{Time.now}]: Record not found"
          return 
        end

        if job.hook['conditions'].nil? || ( !job.hook['conditions'].map{|c| eval(c,binding) ? true : false }.include?(false) )

          run

        else
          
          Jobs.logger.warn "Conditions failed, CONDITIONS: #{job.hook['conditions']} RECORD: #{self.record}"          
          job.update(result: {error: "Conditions failed"})
          
        end
        
      end
      
      private
      
      def run
        begin
          result = perform
        rescue Exception => e
          job.update(result: {error: {message: e.message, stack: e.respond_to?(:backtrace) ? e.backtrace : e.inspect}})
          Jobs.logger.error e
        end
        job.update(result: result)
      end
      
    end
    
  end
end