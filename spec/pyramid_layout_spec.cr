require "./spec_helper"
require "../src/pyramid_layout"

describe PyramidLayout do
  pl = PyramidLayout.new
  it "provides 144 positions" do
    pl.positions_data.size.should eq(144)
    pl.positions.size.should eq(144)

  end
  it "provides 144 top blocks" do
    pl.top_blocks.size.should eq(144)
  end
  it "provides 144 left_blocks" do
    pl.left_blocks.size.should eq(144)
  end
  it "provides 144 right_blocks" do
    pl.right_blocks.size.should eq(144)
  end
end
