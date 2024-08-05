require "crsfml"

class ImagesCreator
  IMAGESDOS = SF::Vector2.new(1026, 730)
  IMAGESMOOTH = SF::Vector2.new(4032, 132)
  getter x_offset : Int32
  getter y_offset : Int32
  getter tile_face_width : Int32
  getter tile_face_height : Int32

  getter locations : Array(Array(Int32))
  getter images : Array(SF::Rect(Int32))
  @texture : SF::Texture
  @offset_multiplier : Int32

  def initialize(texture : SF::Texture)
    @texture = texture
    imagesdef = ImagesSmooth.new
    imagesdef = ImagesDos.new if texture.size == IMAGESDOS
    @x_offset = imagesdef.x_offset
    @y_offset = imagesdef.y_offset
    @tile_face_width = imagesdef.tile_face_width
    @tile_face_height = imagesdef.tile_face_height
    @offset_multiplier = imagesdef.offset_multiplier
    @locations = imagesdef.locations
    @images = get_images()
  end

  def get_images()
    images = [] of SF::Rect(Int32)
    display_width = @tile_face_width + @x_offset
    display_height = @tile_face_height + @y_offset

    @locations.each do |loc|
      x = (loc[0] * (@tile_face_width + @x_offset * @offset_multiplier))
      y = (loc[1] * (@tile_face_height + @y_offset * @offset_multiplier))
      images << SF.int_rect(x, y + @y_offset * (@offset_multiplier - 1), display_width, display_height)  
    end
    return images
  end
end

class ImagesSmooth
  getter x_offset = 12
  getter y_offset = 12
  getter tile_face_width = 84
  getter tile_face_height = 120
  getter offset_multiplier = 1

  getter locations = [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [8, 0],
    [9, 0], [10, 0], [11, 0], [12, 0], [13, 0], [14, 0], [15, 0], [16, 0], [17, 0], [18, 0], 
    [19, 0], [20, 0], [21, 0], [22, 0], [23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0],
    [29, 0], [30, 0], [31, 0], [32, 0], [33, 0], [34, 0], [35, 0], [36, 0], [37, 0], [38, 0],
    [39, 0], [40, 0], [41, 0]]

end

class ImagesDos
  getter x_offset = 10
  getter y_offset = 10
  getter tile_face_width = 94
  getter tile_face_height = 126
  getter offset_multiplier = 2

  getter locations = [
      [0,0],[1,0],[2,0],[3,0],[4,0],[5,0],[6,0],[7,0],[8,0],
      [0,1],[1,1],[2,1],[3,1],[4,1],[5,1],[6,1],[7,1],[8,1],
      [0,2],[1,2],[2,2],[3,2],[4,2],[5,2],[6,2],[7,2],[8,2],
      [4,3],[5,3],[6,3],[7,3],[4,4],[5,4],[6,4],
      [0,3],[1,3],[2,3],[3,3],[0,4],[1,4],[2,4],[3,4]
    ]
end

