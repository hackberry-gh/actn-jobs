$stdout.sync = true
$stderr.sync = true

require 'actn/db'
require 'actn/jobs/job'
require 'i18n'
require 'base64'
require 'securerandom'
require 'websocket/eventmachine/client'

module Actn
  module Jobs
    class Notifier
      
      CHANNEL = "live".freeze
      TTL = 120
      
      I18n.enforce_available_locales = false
    
      def self.start
        
        # pg = Actn::DB.pg

        pg =  PG::EM::Client.new(Actn::DB.db_config.dup.tap{|s| s.delete(:size) })
        
        EM.run do
          
          puts "WS URI #{ENV['WS_URI']}"
          ws = WebSocket::EventMachine::Client.connect(:uri => ENV['WS_URI'])
          
          notify_proc = Proc.new { |notify| 
            
            Jobs.logger.info notify[:extra].inspect
            
            if notify[:extra]
              EventMachine.next_tick do
                ws.send notify[:extra] 
              end
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