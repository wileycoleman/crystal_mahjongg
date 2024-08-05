require "./spec_helper"
require "../src/images_creator"

describe ImagesCreator do

  it "creates tiles images for smooth tiles" do
    texture = SF::Texture.new(4032, 132)
    images_creator = ImagesCreator.new(texture)
    images_smooth = ImagesSmooth.new
    images_creator.tile_face_width.should eq images_smooth.tile_face_width
  end

  it "creates tiles images for dos tiles" do
    texture = SF::Texture.new(1026, 730)
    images_creator = ImagesCreator.new(texture)
    images_dos = ImagesDos.new
    images_creator.tile_face_width.should eq images_dos.tile_face_width
  end
end

describe ImagesDos do
  it "should have locations for 42 tiles" do
    images_dos = ImagesDos.new
    images_dos.locations.size.should eq 42
  end
end


describe ImagesSmooth do
  it "should have locations for 42 tiles" do
    images_smooth = ImagesSmooth.new
    images_smooth.locations.size.should eq 42
  end
end