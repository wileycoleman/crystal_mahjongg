require "baked_file_system"
require "crsfml"

class InternalFiles
  extend BakedFileSystem

  bake_folder "./support/tiles"
  bake_folder "./support/icons"


  def self.file_texture(filename)
    stream = file_stream(filename)
    return SF::Texture.from_stream(stream)
  end

  def self.file_stream(filename)
    ifile = get(filename)
    string = ifile.gets_to_end
    return SF::MemoryInputStream.open(string.to_slice)
  end

end

