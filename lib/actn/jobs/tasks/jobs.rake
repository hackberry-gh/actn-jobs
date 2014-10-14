require "actn/jobs"
require "actn/jobs/notifier"
    
namespace :jobs do
  desc "runs job worker"
  task :work do
    Actn::Jobs::Worker.start
  end
  desc "runs notifier worker" 
  task :notify do
    Actn::Jobs::Notifier.start
  end
end