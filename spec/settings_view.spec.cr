require "./spec_helper"
require "../src/settings_view"

describe SettingsView do
  texture = SF::RenderTexture.new(100,100)
  settingsView = SettingsView.new(texture)
  it "change_image_file" do
    old_file_path = settingsView.file_path
    settingsView.change_image_file("./src/support/icons/settings.png")
    settingsView.file_path.should eq("./src/support/icons/settings.png")
  end

end
