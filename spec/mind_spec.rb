load "lib/Olib/character/mind.rb"
load "stubs.rb"

RSpec.describe Mind do
  ##
  ## test all possible mind states
  ##
  Mind.states.each_pair { |name, str|
    method = (name.to_s + "?").to_sym
    it "Mind##{method}" do
      expect(Mind.send(method)).to be false
      Stubs.mind=str
      expect(Mind.send(method)).to be true
    end
  }

end