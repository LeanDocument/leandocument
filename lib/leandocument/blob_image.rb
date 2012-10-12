module Leandocument
  class BlobImage
    attr_accessor :path, :base_path, :repository, :commit, :web_path
    def initialize(options = {})
      self.path = options[:path]
      self.base_path = options[:base_path] || Dir.pwd
      self.web_path  = "#{options[:web_path]}/"
      self.repository = options[:repository]
      self.commit     = options[:commit]
    end
    
    def find_file(tree = nil, path = nil)
      path = path || self.path
      paths = path.split("/")
      file_name = paths.last
      paths = paths[0..-2]
      (tree || self.commit.tree).contents.each do |content|
        if paths.size > 0
          return find_file(content, (paths[1..-1].push(file_name)).join("/")) if content.name == paths[0]
        else
          return content if content.name == file_name
        end
      end
    end

    def image
      if self.commit
        return find_file ? find_file.data : nil
      end
      f?? open(file_path).read : nil
    end
    
    def f?
      File.exist?(file_path)
    end
    
    def file_path
      "#{self.base_path}/#{self.path}"
    end
  end
end
