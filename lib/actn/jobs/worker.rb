$stdout.sync = true
$stderr.sync = true

require 'actn/db'
require 'actn/jobs/job'
require 'i18n'

module Actn
  module Jobs
    
    class Worker
      
      CHANNEL = "jobs".freeze
      
      I18n.enforce_available_locales = false
    
      def self.start
      
        # pg = Actn::DB.pg
        pg =  PG::EM::Client.new(Actn::DB.db_config.dup.tap{|s| s.delete(:size) })
        
        EM.run do
          
          notify_proc = Proc.new { |notify| 
            
            raise JobError.new("Payload Missing") unless payload = (Oj.load(notify[:extra]) rescue nil)
              
            raise JobError.new("Job not found") unless job = Job.find(payload['uuid'])
              
            hook = job.hook
              
            raise JobError.new("Hook name missing") unless hook['name']
                
            raise JobError.new("Hook class missing") unless hook_class = (Object.const_get(hook['name']) rescue nil)
              
            if (run_at = ((Time.parse(hook['run_at']) rescue nil) || eval(hook['run_at']))  ) > Time.now
                
              EM.add_timer(run_at - Time.now, proc{ notify_proc.call(notify) })
                
            else              
        
              hook_class.new(job).test_and_perform
                
            end  
              

          }
          
          error_proc = Proc.new { |ex|
            Jobs.logger.error ex
          }
          
          wait_proc = Proc.new { |notify|
            
            notify_proc.call(notify) if notify
          
            pg.wait_for_notify_defer.callback(&wait_proc).errback(&error_proc)
            
          }
        
          pg.wait_for_notify_defer.callback(&wait_proc).errback(&error_proc)
        
          pg.query_defer("LISTEN #{CHANNEL}")
        
        end
      

      end

    end
  end

end