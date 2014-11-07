# for defining containers ala lootsack and using them across scripts
module Olib
  class Container < Gameobj_Extender
    attr_accessor :ref, :types, :full

    def initialize(id)
      # set the default value of full being false, we can only know by attempting to add something
      @full = false

      # extract the class name to attempt to lookup the item by your settings
      # ex: class Lootsack
      # ex: class Gemsack
      setting = self.class.name.downcase
      
      @ref = GameObj[@id] || (GameObj.inv.find { |obj| obj.name =~ /\b#{Regexp.escape(UserVars.send(setting).strip)}$/i } || GameObj.inv.find { |obj| obj.name =~ /\b#{Regexp.escape(UserVars.send(setting)).sub(' ', ' .*')}$/i } || GameObj.inv.find { |obj| obj.name =~ /\b#{Regexp.escape(UserVars.send(setting)).sub(' ', ' .*')}/i })

      return "error: failed to find your #{setting.to_s}" unless @ref 
       
      fput "look in ##{@ref.id}" unless GameObj[@ref.id].contents
      self._extend(@ref)._constructor
      
    end


    def worn?
      GameObj.inv.collect { |item| item.id }.include? @ref.id
    end

    def [](query)
      return contents.select do |item| 
        item if (item.type =~ query || item.noun =~ query || item.name =~ query)
      end
    end

    def contents
      contents = []
      @types.each do |method, exp| contents.push self.send method.to_sym end
      return contents.flatten.uniq(&:id)
    end

    def _constructor
      singleton  = (class << self; self end)
      @types    = { #method       => #regex
                    "gems"        => /gem/, 
                    "boxes"       => /box/, 
                    "scrolls"     => /scroll/,
                    "herbs"       => /herb/,
                    "jewelry"     => /jewelry/,
                    "magic"       => /magic/,
                    "clothing"    => /clothing/,
                    "uncommons"   => /uncommon/,
                    "unknowns"    => nil
                  }
      @types.each do |method, exp|
        singleton.send :define_method, method.to_sym do

          matches = exp.nil? ? 
            GameObj[@id].contents.select do |item| item.type.nil?   end : 
            GameObj[@id].contents.select do |item| item.type =~ exp end

          matches.map! do |item| eval("Olib::#{method.gsub(/es$/,'').gsub(/s$/, '').capitalize!}").new(item) end
          
          matches
        end
      end
    end

    def __verbs__
      @verbs = 'open close analyze inspect weigh'.split(' ').map(&:to_sym)
      singleton = (class << self; self end)
      @verbs.each do |verb|
        singleton.send :define_method, verb do
          fput "#{verb.to_s} ##{@id}"
        end
      end
    end

    def full?
      return @full
    end

    def add(item)
      result = Olib.do "_drag ##{item.id} ##{@id}", /#{[Olib::Gemstone_Regex.put[:success], Olib::Gemstone_Regex.put[:failure].values].flatten.join('|')}/
      @full = true if result =~ /won't fit in the/
      self
    end
  end

end