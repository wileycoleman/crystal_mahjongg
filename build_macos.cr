#!/usr/bin/env crystal
require "file_utils"

contrib_dir = "./contrib/macos/Crystal Mahjongg.app"
if Dir.exists?(contrib_dir)
  FileUtils.cp_r(contrib_dir, ".")
  status = Process.run("shards", ["build"])
  if status.exit_code == 0
    # success!
    FileUtils.mkdir("./Crystal Mahjongg.app/Contents/MacOS") unless Dir.exists?("./Crystal Mahjongg.app/Contents/MacOS")
    FileUtils.mkdir("./Crystal Mahjongg.app/Contents/Resources") unless Dir.exists?("./Crystal Mahjongg.app/Contents/Resources")
    FileUtils.cp("./bin/crystal_mahjongg", "./Crystal Mahjongg.app/Contents/MacOS/crystal_mahjongg")
    puts "Build complete!"
    exit 0
  else
    puts "Build failed!"
    exit 1
  end
else
  puts "Mac App skeleton doesnt exist"
  exit 1
end
