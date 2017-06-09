# Class to interact with gems
# overwriting Gem is a bad idea
class Jewel < Olib::Item
  attr_accessor :quality, :value
  
  def appraise
    result = dothistimeout "appraise ##{@id}", 3, /#{Olib::Dictionary.gems[:appraise].values.join('|')}/
    case result
      when Olib::Dictionary.gems[:appraise][:gemshop]
        # handle gemshop appraisal
        @value = $1.to_i
      when Olib::Dictionary.gems[:appraise][:player]
        @value = $3.to_i
        @quality = $2
      when Olib::Dictionary.gems[:appraise][:failure]
        waitrt?
        self.appraise
      else
        respond result
        Client.notify "Error during gem appraisal"
    end
  end

  def normalized_name
    Olib::Dictionary.gems[:singularize].call(@name)
  end
  
  def sell
    result = take
    fput "sell ##{@id}" if result =~ Olib::Dictionary.get[:success]
  end
end
