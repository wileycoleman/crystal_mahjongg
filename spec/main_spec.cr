require "./spec_helper"
require "../src/main"

describe Main do
  # create a main without the game loop or window displayed
  no_show_main = Main.new(false)

  describe "process_action" do
    no_show_main = Main.new(false)
    it "close_settings" do
      no_show_main.process_action("close_settings")
      no_show_main.settings.should be_false
    end
    it "settings" do
      no_show_main.process_action("settings")
      no_show_main.settings.should be_true
    end
    it "change_tiles" do
      no_show_main.process_action("change tiles")
      no_show_main.settings.should be_false
    end
    it "new_game" do
      old_game_number = no_show_main.game_number
      no_show_main.process_text(50)
      no_show_main.game_number.should eq(old_game_number)
      no_show_main.process_action("new_game")
      no_show_main.game_number.should_not eq(old_game_number)
    end
  end

  describe "process_text"  do
    it "does not append other characters" do
      before_string = no_show_main.new_game_number_string
      no_show_main.process_text(47)
      no_show_main.new_game_number_string.should eq(before_string)
    end
    it "appends numbers" do
      game_number = no_show_main.game_number
      no_show_main.process_text(49)
      no_show_main.new_game_number_string.should eq(game_number.to_s + "1")
    end
    it "deletes numbers" do
      before_string = no_show_main.new_game_number_string
      no_show_main.process_text(8)
      no_show_main.new_game_number_string.size.should eq(before_string.size - 1)
    end
  end

  describe "start_new_game" do
    it "updates game number"do
      old_game_number = no_show_main.game_number
      no_show_main.process_text(50)
      no_show_main.game_number.should eq(old_game_number)
      no_show_main.start_new_game
      no_show_main.game_number.should_not eq(old_game_number)
    end
  end
end




