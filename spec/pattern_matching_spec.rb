load "lib/Olib/pattern_matching/result.rb"
load "lib/Olib/pattern_matching/ok.rb"
load "lib/Olib/pattern_matching/err.rb"
load "lib/Olib/pattern_matching/where.rb"
require "ostruct"

RSpec.describe Result do
  it "constructs" do
    expect(Result.new(nil)).to eq(Result[nil])
  end
end

RSpec.describe Ok do
  it "compares class" do
    expect(Ok[taters: 1]).to eq(Ok)
  end

  it "compares content" do
    ok = Ok[taters: 1, hot: true]
    expect(ok).to eq({taters: 1})
    expect(ok).to eq(Ok[taters: 1])
    expect(ok).not_to eq({taters: 1, hot: false})
    expect(Ok[1]).not_to eq(0)
    expect(Ok[1]).to eq(1)
    expect(Ok[1]).not_to eq(Err[1])
  end

  it "can be lambda'd" do
    expect([Ok[1], Ok[2], Ok[3], Err[4]].select(&Ok[2]).size).to eq(1)
  end
end

RSpec.describe Where do
  it "lambda filters" do
    where_filter = [OpenStruct.new(a: 1), OpenStruct.new(a: 1, b: 2), OpenStruct.new(c: 1)].select(&Where[a: 1])
    expect(where_filter.size).to eq(2)
  end
end

RSpec.describe Err do
  it "compares class" do
    expect(Err[why: "boom"]).to eq(Err)
  end

  it "compares content" do
    expect(Err[taters: 1]).to eq({taters: 1})
  end
end