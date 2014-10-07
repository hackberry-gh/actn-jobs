require 'minitest_helper'
require 'actn/db'

module Actn
  module Jobs
    
    class TestJobs < MiniTest::Test
      
      def setup
       
        @wrk_pid = fork do
          Worker.start
        end
        Process.detach @wrk_pid
        
        @model = DB::Model.create(
        {
          name: "Car",
          hooks: { 
            after_create: [
              {
                name: "Trace",
                run_at: Time.now + 2 # 2 seconds later
              },
              {
                name: "Trace"
              }
            ],
            after_update: [
              {
                name: "Trace",
                conditions: [
                  "record['first_name'] == 'Bonzo'"
                ]
              }
            ],
            after_destroy: [
              {
                name: "Trace"
              }          
            ]
          }
        }
        )
        # puts @model.inspect
        
        
      end
      
      def teardown
        Process.kill 'TERM', @wrk_pid
        @model.destroy
      end
      
      def test_jobs
        json = DB::Set['cars'].upsert(brand: "Ford")
        uuid = Oj.load(json)['uuid']

        # puts Job.all.inspect

        assert_equal 2, Job.count({where: {'hook.callback' => "after_create"}})
        
        DB::Set['cars'].upsert(uuid: uuid, brand: "Ford", year: 1989)        
        assert_equal 1, Job.count({where: {'hook.callback' => "after_update"}})
        
        sleep 3
                        
        DB::Set['cars'].delete(uuid: uuid)        
        assert_equal 1, Job.count({where: {'hook.callback' => "after_destroy"}})
      end

    end

  end
end