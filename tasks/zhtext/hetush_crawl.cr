files = Dir.glob("var/chaps/.html/hetushu/*.tsv")

files.each do |file|
  puts file

  Process.run("bin/crawler", args: ["-i", file, "--gzip", "--skip"], output: :inherit)
  Process.run("bin/hetushu_token", args: [file], output: :inherit)
end
