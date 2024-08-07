require "crsfml"
require "./mahjongg_view"
require "./settings_view"

class Main
  getter game_number : Int32
  getter new_game_number_string : String
  @main_window = SF::RenderWindow.new
  getter settings : Bool

  def initialize(show = true)
    desktop = SF::VideoMode.desktop_mode
    width = (desktop.width * 0.7).to_i
    aspect_height = (width * 0.8).to_i
    puts aspect_height
    max_height =  (desktop.height * 0.9).to_i
    puts max_height
    height = aspect_height < max_height ? aspect_height : max_height
    puts "width #{width},height #{height}"
  # test for 1728 vs 1118
    @main_window = SF::RenderWindow.new(
      SF::VideoMode.new(width, height, desktop.bits_per_pixel), "Crystal Mahjongg",
    ) if show
    @main_window.vertical_sync_enabled = true
    @settings = false

    @game_number = Random.new.rand(5000)
    @new_game_number_string = @game_number.to_s

    @game_texture = SF::RenderTexture.new(width, height)
    @game_view = MahjonggView.new(@game_texture, @game_number)

    @settings_texture = SF::RenderTexture.new(width, height)
    @settings_view = SettingsView.new(@settings_texture)
    @main_sprite = SF::Sprite.new(@game_texture.texture)
    @main_window.clear(SF::Color::White)
    @main_window.draw(@main_sprite)
    game_loop if show
  end

  def game_loop

    while @main_window.open?
    
      while event = @main_window.poll_event()
        if event.is_a?(SF::Event::Closed) || (
          event.is_a?(SF::Event::KeyPressed) && event.code.escape?
        )
        @main_window.close()
        end
        if event.is_a?(SF::Event::MouseButtonPressed)
          local_pos = SF::Mouse.get_position(@main_window)
          global_pos = @main_window.map_pixel_to_coords(local_pos)
          if @settings
            action = @settings_view.process_click(global_pos)
          else
            action = @game_view.process_click( global_pos)
          end
          process_action(action)
        end

        if event.is_a?(SF::Event::TextEntered) && !@settings
          process_text(event.unicode)
        end
      end
     update_window()
    end
  end

  def process_action(action)
    case action
    when "close_settings"
      @settings = false
    when "settings"
      @settings = true
    when "change tiles"
      @settings = false
      change_tile_set()
    when "new_game"
      start_new_game()
    end
  end

  def start_new_game()
    if @new_game_number_string.size > 0
      @game_number = @new_game_number_string.to_i
    end
    @game_view.new_game(@game_number)
  end

  def process_text(ucode)
    if ucode > 47 && ucode < 58
      # numeric digit key so update number as long as its only 8 digits long 
      if @new_game_number_string.size < 9
        @new_game_number_string = @new_game_number_string + ucode.chr
      end
    end
    if ucode == 8
      # backspace key so remove right most character
      if @new_game_number_string.size > 0
        @new_game_number_string = @new_game_number_string.rchop
      end
    end
  end

  def update_window()
    @main_window.clear()
    if @settings
      @settings_view.draw_settings()
      @main_sprite.texture = @settings_texture.texture
    else
      @game_view.draw_board(@new_game_number_string)
      @main_sprite.texture = @game_texture.texture
    end
    @main_window.draw(@main_sprite)
    @main_window.display
    GC.collect
  end

  def change_tile_set()
    new_path = @settings_view.file_path
    if new_path != ""
      file_path = @settings_view.file_path
      @game_view.change_image_file(file_path)
    end
    @game_view.background_color = @settings_view.background_color
  end

end