require "actn/paths"
require "actn/db"
require "actn/jobs/version"
require "actn/jobs/job_error"
require "actn/jobs/job"
require "actn/jobs/worker"
require "actn/jobs/base"
require 'actn/hooks'
require 'logger'

module Actn
  module Jobs
    
    include Paths
    
    def self.logger
      @@logger ||= begin
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        logger
      end
    end
    
    def self.gem_root
      @@gem_root ||= File.expand_path('../../../', __FILE__)
    end
    
  end
end

Actn::DB.paths << Actn::Jobs.gem_root