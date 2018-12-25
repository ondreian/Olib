load "lib/Olib/pattern_matching/outcome.rb"

require "ostruct"

RSpec.describe Outcome do
 
  it "prepares a statement" do
    outcome = Outcome.new(%(^You ask the pawnbroker to appraise a <a exist="{{id}}" noun="{{noun}}">{{name}}</a>.$))
    expect(%(You ask the pawnbroker to appraise a <a exist="1297378" noun="scarab">blood red teardrop-etched scarab</a>.))
      .to match(outcome.prepare(
        id:   "1297378", 
        noun: "scarab", 
        name: "blood red teardrop-etched scarab"))
  end
end