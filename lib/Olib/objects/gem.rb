# Class to interact with gems
module Olib
  class Gem < Gameobj_Extender
    attr_accessor :quality, :value
    def appraise
      result = dothistimeout "appraise ##{@id}", 3, /#{Gemstone_Regex.gems[:appraise].values.join('|')}/
      case result
        when Gemstone_Regex.gems[:appraise][:gemshop]
          # handle gemshop appraisal
          @value = $1
        when Gemstone_Regex.gems[:appraise][:player]
          @value = $3
          @quality = $2
        when Gemstone_Regex.gems[:appraise][:failure]
          waitrt?
          self.appraise
        else
          respond result
          Client.notify "Error during gem appraisal"
      end
    end
    def normalized_name
      Gemstone_Regex.gems[:singularize].call(@name)
    end
    def sell
      result = take
      fput "sell ##{@id}" if result =~ Gemstone_Regex.get[:success]
    end
  end
end