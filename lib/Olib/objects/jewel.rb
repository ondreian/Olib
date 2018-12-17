# Class to interact with gems
# overwriting Gem is a bad idea
class Jewel < Item
  attr_accessor :quality, :value
  
  def appraise
    result = dothistimeout "appraise ##{@id}", 3, /#{Dictionary.gems[:appraise].values.join('|')}/
    case result
      when Dictionary.gems[:appraise][:gemshop]
        # handle gemshop appraisal
        @value = $1.to_i
      when Dictionary.gems[:appraise][:player]
        @value = $3.to_i
        @quality = $2
      when Dictionary.gems[:appraise][:failure]
        waitrt?
        self.appraise
      else
        respond result
        Client.notify "Error during gem appraisal"
    end
  end

  def normalized_name
    Dictionary.gems[:singularize].call(@name)
  end
  
  def sell
    result = take
    fput "sell ##{@id}" if result =~ Dictionary.get[:success]
  end
end
