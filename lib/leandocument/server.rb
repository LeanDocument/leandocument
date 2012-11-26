module Leandocument
  # Your code goes here...
  class Server < Sinatra::Base
    register Sinatra::Partial
    set :sessions, true
    set :root, Dir.pwd
    set :output, nil
    set :partial_template_engine, :erb
    enable :partial_underscores
    set :public_folder, File.dirname(File.dirname(File.dirname(__FILE__))) + '/public'
    set :views,         File.dirname(File.dirname(File.dirname(__FILE__))) + '/views'
    set :embed, nil
    
    def self.start(options = {})
      set :output, options[:output]
      if options[:output]
        set :embed, true
      end
      self.run!(options)
    end
    
    helpers do
      def embed_stylesheet(url)
        unless settings.embed
          return "<link href='#{url}' rel='stylesheet'>"
        end
        if url =~ /^\//
          path = "#{settings.public_folder}/#{url}"
          if File.exist?(path)
            return "<style>#{open(path).read}</style>"
          end
        else
          begin
            return "<style>#{open(url).read}</style>"
          rescue
          end
        end
      end
      
      def embed_javascript(url)
        unless settings.embed
          return "<script type='text/javascript' src='#{url}'></script>"
        end
        if url =~ /^\//
          path = "#{settings.public_folder}/#{url}"
          if File.exist?(path)
            return "<script type='text/javascript'>#{open(path).read}</script>"
          end
        else
          begin
            return "<script type='text/javascript'>#{open(url).read}</script>"
          rescue
          end
        end
      end
    end
    
    get '/' do
      @doc = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2])
      body = erb(:index)
      if settings.embed
        path = "#{settings.output}index.html"
        File.open(path, "w") do |f|
          body = body.gsub(/<img( .*?)src=\"/, "<img#{'\\1'}src=\".")
          f.write body
        end
      end
      body
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
          if settings.embed
            file_path = "#{settings.output}#{path}"
            unless File.exist?(File.dirname(file_path))
              FileUtils.mkdir_p(File.dirname(file_path))
            end
            File.open(file_path, "w") do |f|
              f.write @blob.image
            end
          end
          send_file @blob.file_path, :type => ext
        end
      end
    end
  end
end
