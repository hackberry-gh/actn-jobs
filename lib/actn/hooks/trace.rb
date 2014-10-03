require 'actn/jobs/base'
    
class Trace < Actn::Jobs::Base
  def perform
    puts "[Trace#perform, #{Time.now}]: #{job.inspect} #{record.inspect}"
  end
end

