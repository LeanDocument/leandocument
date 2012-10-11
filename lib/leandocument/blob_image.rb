module Leandocument
  class BlobImage
    attr_accessor :path, :base_path
    def initialize(options = {})
      self.path = options[:path]
      self.base_path = options[:base_path] || Dir.pwd
    end
    
    def image
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
