module Leandocument
  class Repository
    attr_accessor :base_path, :repo
    
    def initialize(options = {})
      self.base_path = options[:base_path] || Dir.pwd
      self.repo      = Grit::Repo.new(self.base_path)
    end
    
    def commits(id = nil)
      id.nil?? self.repo.commits : self.repo.commits(id).first
    end
  end
end
