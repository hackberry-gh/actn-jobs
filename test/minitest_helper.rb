$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$stdout.sync = true
$stderr.sync = true

require 'actn/jobs'

require 'minitest/autorun'
require 'minitest/pride'

ENV['RACK_ENV'] = "test"
ENV['DATABASE_URL'] ||= "postgres://localhost:5432/actn_test" 
I18n.enforce_available_locales = false

class  MiniTest::Test
  private
  
  def random_str
    (0...8).map { (65 + rand(26)).chr }.join
  end
end
