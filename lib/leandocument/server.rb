Raven.configure do |config|
  config.dsn = 'https://65b7938acfbc45a0882bb8c80392b189:43d9098ad5124dfcbf188b08343dde80@app.getsentry.com/2978'
end

module Leandocument
  # Your code goes here...
  class Server < Sinatra::Base
    register Sinatra::Partial
    set :sessions, true
    set :root, Dir.pwd
    set :partial_template_engine, :erb
    enable :partial_underscores
    set :public_folder, File.dirname(File.dirname(File.dirname(__FILE__))) + '/public'
    set :views,         File.dirname(File.dirname(File.dirname(__FILE__))) + '/views'
    def self.start(options = {})
      use Raven::Rack
      Raven.capture do
        self.run!(options)
      end
    end
    
    get '/' do
      @doc = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2])
      erb :index
    end
    
    get '/commits' do
      @repo = Repository.new
      @commits = @repo.commits
      erb :commits
    end
    
    get '/branches' do
      @repo = Repository.new
      erb :branches
    end
    
    get '/branches/:id' do
      @repo = Repository.new
      @commit = @repo.commits(params[:id]).first
      @doc  = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2], :repository => @repo, :commit => @commit)
      erb :index
    end
    
    get '/branches/:id/commits' do
      @repo = Repository.new
      puts "params[:id] -> #{params[:id]}"
      @commits = @repo.commits(params[:id])
      puts "@commits -> #{@commits}"
      erb :commits
    end
    
    get '/commits/:id' do
      @repo = Repository.new
      @commit = @repo.commits(params[:id]).first
      @doc  = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2], :repository => @repo, :commit => @commit)
      erb :index
    end
    
    %w(png jpg gif jpeg).each do |ext|
      get "/commits/:id/*.#{ext}" do
        @repo = Repository.new
        @commit = @repo.commits(params[:id]).first
        path = "#{params[:splat].join("/")}.#{ext}"
        @blob = BlobImage.new(:path => path, :commit => @commit, :repository => @repo)
        if @blob.f?
          content_type ext
          @blob.image
        end
      end
      get "/*.#{ext}" do
        path = "#{params[:splat].join("/")}.#{ext}"
        @blob = BlobImage.new(:path => path)
        if @blob.f?
          send_file @blob.file_path, :type => ext
        end
      end
    end
  end
end
