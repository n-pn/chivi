Dir.glob("var/ys_db/crits/*/").each do |text_dir|
  puts text_dir

  zip_file = text_dir.sub(/\/$/, ".zip")

  `zip --include=\\*.txt -rjmq "#{zip_file}" "#{text_dir}"`
  Dir.delete(text_dir)
end
