module Leandocument
  class Repository
    attr_accessor :base_path, :repo
    
    def initialize(options = {})
      self.base_path = options[:base_path] || Dir.pwd
      self.repo      = Grit::Repo.new(self.base_path)
    end
    
    def commits(id = nil)
      id.nil?? self.repo.commits : self.repo.commits(id)
    end

    def branches(id = nil)
      id.nil?? self.repo.branches : self.repo.branches(id).first
    end
  end
end
