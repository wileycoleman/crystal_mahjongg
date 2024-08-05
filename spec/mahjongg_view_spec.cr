require "./spec_helper"
require "../src/mahjongg_view"

describe MahjonggView do
  texture = SF::RenderTexture.new(100,100)
  mahjonggView = MahjonggView.new(texture)
  it "new_game" do
    old_game = mahjonggView.game_number
    mahjonggView.new_game(old_game * 2)
    mahjonggView.game_number.should eq(old_game * 2)
  end

end
