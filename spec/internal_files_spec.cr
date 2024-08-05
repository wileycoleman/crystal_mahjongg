require "./spec_helper"
require "../src/internal_files"

describe InternalFiles do
  it "file_texture" do
    texture = InternalFiles.file_texture("settings.png")
    texture.class.should eq(SF::Texture)
  end
  it "file_stream" do
    stream = InternalFiles.file_stream("settings.png")
    stream.class.should eq(SF::MemoryInputStream)
  end

end
