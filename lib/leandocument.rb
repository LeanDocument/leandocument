require "leandocument/version"

module Leandocument
  # Your code goes here...
  class Server < Sinatra::Base
    attr_accessor :path
    set :sessions, true
    set :root, Dir.pwd
    def self.start
      self.run!
    end
    
    get '/' do
      lang = @env["HTTP_ACCEPT_LANGUAGE"][0,2]
      base = Dir.pwd
      file_path = "#{base}/README.#{lang}.md"
      if File.exist?(file_path)
        content = open(file_path).read
        markdown = RDiscount.new(content)
        page = markdown.to_html
        path = File.dirname(file_path)
        Dir.entries(path).map do |f|
          expand_path = File.expand_path(f, path)
          if File.directory?(expand_path)
            file_path = "#{expand_path}/README.#{lang}.md"
            if File.exist?(file_path)
              content = open(file_path).read
              content = content.to_s.gsub(/^#/, "## ")
              markdown = RDiscount.new(content)
              page += "\n#{markdown.to_html}"
            end
          end
        end
        return page
      end
    end
  end
end
