class MahjonggModel
  getter tiles : Array(Tile)
  getter free : Array(Tile)
  getter possible_matches : Array(Array(Tile))

  getter game_number
  getter possible_matches
  #find the position_id for a given tile_id
  getter tile_to_position_map : Array(Int32)

  #find the tile_id for a given position_id
  getter position_to_tile_map : StaticArray(Int32, 144)

  @top_blocks : Array(Array(Int32))
  @left_blocks : Array(Array(Int32))
  @right_blocks : Array(Array(Int32))

  getter matches : Array(Array(Int32))

  def initialize(layout, game_number : Int = 10)
    # Positions array maps tiles to positions
    @top_blocks = layout.top_blocks
    @left_blocks = layout.left_blocks
    @right_blocks = layout.right_blocks
    @matches = Array(Array(Int32)).new
    @tile_to_position_map = shuffle_position(game_number)
    @position_to_tile_map = create_position_to_tile()
    @tiles = create_tiles()
    @selected = -1
    @game_number = game_number
    @free = [] of Tile
    @possible_matches = find_matches()

  end
  
  class Tile
    getter tile_id, group, position_id, image_id
    property? visible : Bool = true
    property? selected : Bool = false

    def initialize(tile_id : Int32, group : Int32, position_id : Int32, image_id : Int32)
      @tile_id = tile_id
      @group = group
      @position_id = position_id
      @image_id = image_id
    end
  end

  # positions are randomly shuffled by a seed. Index of this array is the tile number
  def shuffle_position( seed : Int)
    tile_positions = (0..143).to_a
    tile_positions.shuffle!(Random.new(seed))
  end

  def create_position_to_tile()
    position_to_tile = uninitialized Int32[144]
    (0..143).to_a.each do |tile|
      pos = tile_to_position_map[tile]
      position_to_tile[pos] = tile
    end
    return position_to_tile
  end
  
  def create_tiles()
    tiles = [] of Tile
    sub_group1 = 0
    sub_group2 = 0
    (0..143).to_a.each do |tile_id|
      group = tile_id % 36
      if group < 34
        image_id = group
      elsif group == 34
        image_id = group + sub_group1
        sub_group1 += 1
      else
        image_id = 38 + sub_group2
        sub_group2 += 1
      end
      tiles << Tile.new(tile_id, group, @tile_to_position_map[tile_id], image_id)
    end
    return tiles
  end


  def process_selection(position_id : Int32)
    # no updates necessary if tile is blocked, its not a valid choice
    return false if blocked_on_top?(position_id) || side_blocked?(position_id)
    # no updates necessary if same tile clicked as last time
    return false if position_id == @selected
    tile = get_tile(position_id)
    #if there is a valid previously selected tile see if they are a match
    if @selected >= 0
      prev_tile = get_tile(@selected)
      prev_tile.selected = false
      @selected = -1
      # valid match if groups match
      if tile.group == prev_tile.group
        tile.visible = false
        prev_tile.visible = false
        @matches << [tile.tile_id, prev_tile.tile_id]
        @possible_matches = find_matches()
        return true
      end
    end
    @selected = position_id  # mark the current pick as the selected tile
    tile.selected = true

    return true
  end

  def find_matches()
    @free = [] of Tile
    @tile_to_position_map.each_with_index do |pos, tile_id|
      tile = @tiles[tile_id]
      free << @tiles[tile_id] if is_free?(pos) && tile.visible?
    end
    new_matches = [] of Array(Tile)
    free_count = free.size
    free.each_with_index do |tile, indx|
      group1 = tile.group
      (indx+1..free_count-1).each do |tile2_id|
        tile2 = free[tile2_id]
        new_matches << [tile, tile2] if tile2.group == group1
      end
    end
    return new_matches
  end

  def is_free?(position)
    !blocked_on_top?(position) && !side_blocked?(position)
  end

  def undo()
    if @matches.last?
      match = @matches.last
      tile1 = tiles[match.first]
      tile1.visible = true
      tile2 = tiles[match.last]
      tile2.visible = true
      @matches.delete(match)
      if @selected >= 0
        prev_tile = get_tile(@selected)
        prev_tile.selected = false
        @selected = -1
      end
      @possible_matches = find_matches()
      return true
    end
    return false
  end


  def blocked_on_top?(position_id : Int32)
    blockers = @top_blocks[position_id]
    blockers.each do | position |
      tile_id = position_to_tile_map[position]
      return true if tiles[tile_id].visible?
    end
    return false
  end

  def side_blocked?(position_id : Int32)
    if any_visible?(@left_blocks[position_id]) && any_visible?(@right_blocks[position_id])
      return true
    else
      return false
    end
  end

  #returns the actual tile object
  def get_tile(position_id)
    tile_id = position_to_tile_map[position_id]
    tile = tiles[tile_id]
  end

  def any_visible?(positions : Array(Int32))
    positions.each do |pos|
      tile = get_tile(pos)
      return true if tile.visible?
    end
    return false
  end

end
