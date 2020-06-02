class Creatures
  module Metadata
    @repo = JSON.parse File.read File.join(__dir__, "creatures.json")

    def self.put(name:, level:, tags: [])
      @repo[name.downcase] = {name: name, level: level, tags: tags}
    end

    def self.get(name)
      @repo.fetch(name.downcase) do {name: name, level: Char.level, tags: []} end
    end
  end
end