require 'actn/jobs/base'
require 'em-http-request'
# require 'httparty'

class WebHook < Actn::Jobs::Base

  class Client

    %w(post get put patch delete).each do |method|
      class_eval <<-CODE
      def #{method} url, params = {}
        request :#{method}, url, params
      end
      CODE
    end

    def request method, url, params = {}
      # unless EventMachine.reactor_running?
      #   http = HTTParty.send(method, url, params.symbolize_keys.tap{|p| p[:headers] = p.delete(:head)})
      # else
        http = EM::HttpRequest.new(url).send method, params
      # end
      # http.response
    end

  end

  def perform
    Fiber.new{
      # puts "[WebHook#perform, #{Time.now}]: #{job.inspect} #{record.inspect}"
      http = client.request(type, url, head: head, query: query, body: Oj.dump(body))
      puts http.try(:response_header).inspect
      puts http.try(:response).inspect      
      {status: http.try(:response_header).try(:status), body: http.try(:response)}    
    }.resume
  end
  
  private
  
  def type
    job.hook['http_method'] || :post
  end
  
  def url
    job.hook["url"]
  end  
  
  def head
    job.hook["head"] 
  end
  
  def query
    job.hook["query"] 
  end
  
  def body
    job.hook["wrap"] ? { "#{job.hook['wrapper']}" => record } : record
  end

  def client
    @client ||= Client.new
  end
  
  
end

