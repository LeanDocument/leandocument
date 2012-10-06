libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require "leandocument/version"
require "sinatra/base"
require "sinatra/reloader"
require "rdiscount"
require 'erb'

module Leandocument
  # Your code goes here...
  class Server < Sinatra::Base
    set :sessions, true
    set :root, Dir.pwd
    set :public_folder, File.dirname(File.dirname(__FILE__)) + '/public'
    set :views,         File.dirname(File.dirname(__FILE__)) + '/views'
    def self.start
      self.run!
    end
    
    get '/' do
      @doc = Document.new(:lang => @env["HTTP_ACCEPT_LANGUAGE"][0,2])
      erb :index
    end
  end
  
  class Document
    attr_accessor :path, :lang, :settings, :base_path, :indent
    
    def initialize(options = {})
      self.lang = options[:lang]
      self.base_path = options[:base_path] || Dir.pwd
      self.indent = options[:indent] || 0
    end
    
    def file_path
      "#{self.base_path}/README.#{self.lang}.md"
    end
    
    def content
      File.exist?(self.file_path) ? open(self.file_path).read : ""
    end
    
    def markdown
      RDiscount.new(exec_trans(content))
    end
    
    def exec_trans(content)
      self.indent.times do |i|
        content = content.to_s.gsub(/^#/, "## ")
      end
      content
    end
    
    def d(f, path)
      return nil if [".", ".."].include?(f)
      expand_path = File.expand_path(f, path)
      File::ftype(expand_path) == "directory" ? expand_path : nil
    end
    
    def to_html
      page = markdown.to_html
      path = File.dirname(file_path)
      Dir.entries(path).map do |f|
        expand_path = d(f, path)
        next unless expand_path
        doc = Document.new :base_path => expand_path, :lang => self.lang, :indent => self.indent + 1
        page += doc.to_html
      end
      page
    end
  end
end

Leandocument::Server.start
