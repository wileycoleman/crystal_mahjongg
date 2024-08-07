require "./internal_files"
require "crsfml"
require "./images_creator"
class SettingsView

  getter file_path : String = ""
  getter background_color = SF.color(15, 82, 186)

  @texture : SF::Texture

  def initialize(window : SF::RenderTexture)
    @window = window
    @block_width = @window.size.x / 16
    @block_height = @window.size.y / 10
    @texture = InternalFiles.file_texture("muted_ivories.png")
    @close_button =  SF::Sprite.new(InternalFiles.file_texture("close.png"))
    @change_file_button =  SF::Sprite.new(InternalFiles.file_texture("folder.png"))
    @update_tiles_button =  SF::Sprite.new(InternalFiles.file_texture("update_tiles.png"))
    @color_picker_button =  SF::Sprite.new(InternalFiles.file_texture("color_picker.png"))
    @images_creator = ImagesCreator.new(@texture)
    draw_settings
  end

  def change_image_file(file_path)
    begin
      new_texture = SF::Texture.from_file(file_path)
    rescue ex
      puts ex.message
      return false
    end
    @file_path = file_path
    @texture = new_texture
    @images_creator = ImagesCreator.new(@texture)
    draw_settings
  end

  def draw_settings
    scale = calculate_scale()
    @window.clear(@background_color)
    draw_settings_buttons(scale)
    draw_tiles(scale)
    @window.display
  end

  def launch_file_chooser
    stdout = IO::Memory.new
    process = Process.run("zenity --file-selection --filename=home",shell: true, output: stdout)
    output = stdout.to_s.rchop
  end

  def launch_color_chooser
    stdout = IO::Memory.new
    process = Process.run("zenity --color-selection",shell: true, output: stdout)
    output = stdout.to_s.rchop.rchop
    output = output.lchop(prefix: "rgb(")
    rgb = output.split(separator: ",").map(&.to_i)
    SF::Color.new(rgb[0], rgb[1], rgb[2])
  end

  def calculate_scale
    @block_width = @window.size.x / 16
    @block_height = @window.size.y / 10
    scale_x = @block_width / @images_creator.tile_face_width
    scale_y = @block_height / @images_creator.tile_face_height
    scale = scale_x < scale_y ? scale_x : scale_y
    return scale
  end

  def draw_settings_buttons(scale)
    draw_button(@close_button, scale, @window.size.x - @block_width, 10)
    draw_button(@color_picker_button, scale, @block_width * 3, 10)
    draw_button(@change_file_button, scale / 2, @block_width, 10)
    draw_button(@update_tiles_button, scale * 1.5, @block_width * 2, 10)
  end

  def draw_button(button, scale, x, y)
    button.set_scale(scale, scale)
    button.position = SF.vector2(x, y)
    @window.draw(button)
  end

  def process_click(pos)
    x = pos.x
    y = pos.y
    return "close_settings" if @close_button.global_bounds.contains?(x,y)
    return "change tiles" if @update_tiles_button.global_bounds.contains?(x,y)
    if @change_file_button.global_bounds.contains?(x,y)
      file_path = launch_file_chooser
      change_image_file(file_path)
    end
    if @color_picker_button.global_bounds.contains?(x,y)
      # launch_color_chooser
      rgb_color = launch_color_chooser
      @background_color = rgb_color
      draw_settings
    end
  end

  def draw_tiles(scale)
    sprites = [] of SF::Sprite
    # create sprites in position order and add to sprites array
    (0..41).each do | indx |
      sprite = SF::Sprite.new(@texture)
      sprite.set_scale(scale,scale)
    
      sprite.texture_rect = @images_creator.images[indx]
      width =  sprite.global_bounds.width
      height = sprite.global_bounds.height
      xcol = indx % 7
      col = width * xcol + xcol * 10
      yrow = (indx/ 7).floor
      row = height * yrow + yrow * 10
      sprite.position = SF.vector2(col + @block_width, row + @block_height)
      sprites << sprite
      @window.draw(sprite)
    end
    return sprites
  end

end