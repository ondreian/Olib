module Interface
  class Queryable
    def self.fetch
      []
    end

    def self.each(&block)
      fetch.each &block
    end

    def self.map(&block)
      fetch.map &block
    end

    def self.find(&block)
      fetch.find &block
    end

    def self.sort(&block)
      fetch.sort &block
    end

    def self.select(&block)
      fetch.select &block
    end

    def self.reject(&block)
      fetch.reject &block
    end

    def self.where(**conds)
    end

    def self.first
      fetch.first
    end

    def self.sample(n = 1)
      fetch.sample n
    end

    def self.empty?
      (fetch || []).empty?
    end

    def self.size
      fetch.size
    end
  end
end