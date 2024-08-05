require "./mahjongg_model"
require "./images_creator"
require "./internal_files"
require "./pyramid_layout"

class MahjonggView
  property background_color = SF.color(15, 82, 186)

  @positions : Array(Position)
  @sprites : Array(SF::Sprite)

  getter game_number : Int32
  @hint = false
  
  def initialize(windowtexture : SF::RenderTexture, game_number = 1)
    @window = windowtexture
    @layout = PyramidLayout.new
    @positions = @layout.positions
    @game_number = game_number
    @model = MahjonggModel.new(@layout, game_number)
    @tiles = @model.tiles
    @texture = InternalFiles.file_texture("muted_ivories.png")
    @images_creator = ImagesCreator.new(@texture)
    
    @block_width = @window.size.x / 16
    @block_height = @window.size.y / 10

    @sprites = create_sprites()

    @settings_button =  SF::Sprite.new(InternalFiles.file_texture("settings.png"))
    @reload_button =  SF::Sprite.new(InternalFiles.file_texture("bold_reload.png"))
    @undo_button =  SF::Sprite.new(InternalFiles.file_texture("undo.png"))
    @bulb_button =  SF::Sprite.new(InternalFiles.file_texture("bulb_off.png"))
    @font = SF::Font.from_stream(InternalFiles.file_stream("LeagueSpartan-Regular.ttf"))
    @game_info_text = SF::Text.new("Game Info: ",@font)
    @board_number_text = SF::Text.new("Board Number: ", @font)
    @rectangle = SF::RectangleShape.new(SF.vector2(@images_creator.tile_face_width, 50))
    @inputted = SF::Text.new(@game_number.to_s, @font)

    draw_board(@game_number.to_s)
  end

  def new_game(game_number)
    @game_number = game_number
    @model = MahjonggModel.new(@layout, game_number)
    @tiles = @model.tiles
    @sprites = create_sprites()
  end

  def change_image_file(file_path)
    @texture = SF::Texture.from_file(file_path)
    @images_creator = ImagesCreator.new(@texture)
    @sprites = create_sprites()
    draw_board(@game_number.to_s)
  end

  def style_text(text : SF::Text)
    text.character_size = 30
    text.style = SF::Text::Bold
    text.color = SF::Color::Black
  end

  def create_sprites
    sprites = [] of SF::Sprite
    # create sprites in position order and add to sprites array
    (0..143).each do | indx |
      tile_number = @model.position_to_tile_map[indx]
      tile = @tiles[tile_number]
      sprite = SF::Sprite.new(@texture)
      sprite.texture_rect = @images_creator.images[tile.image_id]
      sprites << sprite
    end
    return sprites
  end

  def calculate_scale()
     # change scale according to current window size (used for resizing of window)
     @block_width = @window.size.x / 16
     # 8 rows of tiles, one more to split and give a border area, and one for the button row at top
     @block_height = @window.size.y / 10
     scale_x = @block_width / @images_creator.tile_face_width
     scale_y = @block_height / @images_creator.tile_face_height
     scale = scale_x < scale_y ? scale_x : scale_y
     return scale
  end

  def draw_board(game_number : String)
    scale = calculate_scale()
    @window.clear(@background_color)

    @positions.each_with_index do | pos, indx | # index is position number
      tile_number = @model.position_to_tile_map[indx]
      tile = @tiles[tile_number]
      sprite = @sprites[indx]
      sprite.set_scale(scale, scale)
      sprite.position = SF.vector2((pos.column/2 * @images_creator.tile_face_width * scale) + @block_width + (@images_creator.x_offset * pos.layer), ((pos.row/2 + 1) * @images_creator.tile_face_height * scale) + @block_height/2 - (@images_creator.y_offset * (pos.layer)))
      sprite.color = tile.selected? ? SF.color(253, 253, 150) : SF.color(255, 255, 255)
      if @hint
        if @model.possible_matches.size > 0 && @model.possible_matches[0].includes?(tile)
          sprite.color = SF.color(144, 238, 144) if !tile.selected?
        end
      end
      sprite.color = SF::Color::Transparent if !tile.visible?  #turns invisible
      
      @window.draw(sprite)
    end
    draw_game_buttons(scale)
    draw_input(game_number, scale)
    draw_info()
    @window.display
  end


  def draw_game_buttons(scale)
    draw_button(@reload_button, scale, @block_width * 3, 10)
    # only show settings icon and allow settings changes if on Linux
    {% if flag?(:unix) %}
      draw_button(@settings_button, scale, @window.size.x - @images_creator.tile_face_width, 10)
    {% end %}
    draw_button(@undo_button, scale,@block_width * 7, 10)
    draw_button(@bulb_button, scale * 1.5, @block_width * 8, 10)
  end

  def draw_button(button, scale, x, y)
    button.set_scale(scale, scale)
    button.position = SF.vector2(x, y)
    @window.draw(button)
  end



  def draw_input(new_number_string : String, scale)
    style_text(@board_number_text)
    @board_number_text.position = SF.vector2(0, 5)
    @window.draw(@board_number_text)

    @rectangle.fill_color = SF::Color::White
    @rectangle.position = SF.vector2(@images_creator.tile_face_width * 2.5, 10)
    @window.draw(@rectangle)

    if @inputted.string != new_number_string
      # need to create font and inputted again or this crashes
      @font = SF::Font.from_stream(InternalFiles.file_stream("LeagueSpartan-Regular.ttf"))
      @inputted = SF::Text.new(new_number_string, @font)
    end
    style_text(@inputted)
    @inputted.position = SF.vector2(@images_creator.tile_face_width * 2.5, 10)
    @window.draw(@inputted)
  end

  def draw_info
    style_text(@game_info_text)
    @game_info_text.character_size = 50
    @game_info_text.string = ""
    @game_info_text.position = SF.vector2(0, 60)
    if @model.possible_matches.size == 0
      @game_info_text.string = "  NO MORE MOVES!" 
      @game_info_text.color = SF::Color::Red
    end
    if @model.matches.size == 72
      @game_info_text.character_size = 100
      @game_info_text.string = "  YOU WON!" 
      @game_info_text.color = SF::Color::Yellow
    end
    @window.draw(@game_info_text)
  end

  # provide the global coordinates and this returns position number
  def find_sprite_position(x, y)
    sprites_count = @sprites.size
    # reverse order needed because of overlapping of tiles
    # last drawn is the visible one that is being clicked
    @sprites.reverse.each_with_index do | sprite, indx |
      if sprite.global_bounds.contains?(x, y)
          return sprites_count - indx - 1 if sprite.color != SF::Color::Transparent
      end
    end
    return -1
  end

  def process_click(pos)
    x = pos.x
    y = pos.y
    reversed = false
    updated = false
    return "settings" if @settings_button.global_bounds.contains?(x,y)
    return "new_game" if @reload_button.global_bounds.contains?(x,y)
    @hint = @bulb_button.global_bounds.contains?(x,y) ? true : false
    reversed = @model.undo if @undo_button.global_bounds.contains?(x,y)
    position = find_sprite_position(x, y)
    updated = @model.process_selection(position) if position >= 0
    draw_board(@game_number.to_s) if reversed || updated
    return ""
  end

end
