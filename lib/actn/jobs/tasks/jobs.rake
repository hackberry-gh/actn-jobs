require "actn/jobs"
    
namespace :jobs do
  desc "runs job worker"
  task :work do
    Actn::Jobs::Worker.start
  end
end