require "./spec_helper"
require "../src/mahjongg_model"
require "../src/pyramid_layout"

describe MahjonggModel do
  # create a main without the game loop or window displayed
  layout = PyramidLayout.new
  game_number = 10
  model = MahjonggModel.new(layout, game_number)

  it "create tiles should create 36 groups of 4 tiles" do
    groups = [] of Int32
    (1..36).to_a.each do |indx|
        groups << 0
    end
    model.tiles.each do |tile|
      groups[tile.group] =  groups[tile.group] + 1
    end
    groups.each do |number|
      number.should eq 4
    end
  end

  it "position to tile and tile to position maps should be inverse" do
    tile_to_pos = model.tile_to_position_map
    pos_to_tile = model.position_to_tile_map
    (0..143).to_a.each do |indx|
      pos_to_tile[tile_to_pos[indx]].should eq indx
    end
  end


  it "shuffle position should be consistent even though using random function" do
    shuffle_model = MahjonggModel.new(layout, game_number)
    map1 = shuffle_model.shuffle_position(game_number)
    map2 = shuffle_model.shuffle_position(game_number)
    map3 = shuffle_model.shuffle_position(game_number + 1)
   #using same seed in random generator should produce the same game
    map1.should eq map2
    map2.should_not eq map3
    map1.size.should eq 144
  end

  it "is free" do
    #sanity checking some known positions are marked as free and not free
    model.blocked_on_top?(0).should be_false
    model.side_blocked?(0).should be_false
    model.side_blocked?(1).should be_true
    model.is_free?(0).should be_true
    model.is_free?(1).should be_false
    model.is_free?(142).should be_false
    model.is_free?(143).should be_true
  end

  it "find matches" do
    matches = model.find_matches
    first_match = matches.first
    tile1 =  first_match[0]
    tile2 = first_match[1]
    tile1.group.should eq tile2.group
    model.is_free?(tile1.position_id).should be_true
    model.is_free?(tile2.position_id).should be_true
  end
  
  it "get_tile" do
    model.get_tile(2).class.should eq MahjonggModel::Tile
  end

  it "any_visible?" do
    possible_matches = model.find_matches
    match = possible_matches.first
    tile1 = match[0]
    tile2 = match[1]
    model.any_visible?([tile1.position_id, tile2.position_id]).should be_true
    model.process_selection(tile1.position_id).should eq true
    model.process_selection(tile2.position_id).should eq true
    model.any_visible?([tile1.position_id, tile2.position_id]).should be_false
  end



  describe "process selection" do
    it "blocked position" do
      model.process_selection(1).should eq false
    end

    it "same position" do
      model.process_selection(0).should eq true
      model.process_selection(0).should eq false
    end

    it "matches" do
      matches = model.find_matches
      first_match = matches.first
      tile1 =  first_match[0]
      tile2 = first_match[1]
      model.process_selection(tile1.position_id).should eq true
      model.process_selection(tile2.position_id).should eq true
    end

  end

  it "undo" do
    possible_matches = model.find_matches
    match = possible_matches.first
    tile1 = match[0]
    tile2 = match[1]
    matches_before = model.matches.size
    model.process_selection(tile1.position_id).should eq true
    model.process_selection(tile2.position_id).should eq true
    model.matches.size.should eq (matches_before + 1)
    model.undo()
    model.matches.size.should eq (matches_before)
  end

end