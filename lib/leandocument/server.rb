module Leandocument
  # Your code goes here...
  class Server < Sinatra::Base
    set :sessions, true
    set :root, Dir.pwd
    set :public_folder, File.dirname(File.dirname(File.dirname(__FILE__))) + '/public'
    set :views,         File.dirname(File.dirname(File.dirname(__FILE__))) + '/views'
    def self.start
      self.run!
    end
    
    get '/' do
      @doc = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2])
      erb :index
    end
  end
end
