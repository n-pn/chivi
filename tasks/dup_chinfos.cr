require "./shared/bootstrap"

DIR = "var/chtexts"

Dir.children(DIR).each do |sname|
  s_dir = File.join(DIR, sname)
  books = Dir.children(s_dir)

  keep_dir = File.join(s_dir, "_")
  FileUtils.mkdir_p(keep_dir)

  books.each do |snvid|
    next if snvid == "_"

    n_dir = File.join(DIR, sname, snvid)
    next unless File.directory?(n_dir)

    files = Dir.glob("#{n_dir}/*.tsv")

    all_infos = {} of Int32 => CV::ChInfo
    txt_infos = {} of Int32 => CV::ChInfo

    files.each do |file|
      if file.ends_with?("-.tsv")
        File.delete(file)
        next
      end

      CV::ChList.new(file).each_value do |info|
        all_infos[info.chidx] = info
        txt_infos[info.chidx] = info if info.chars > 0
      end
    end

    puts "\n #{n_dir}"
    puts "- Total: #{all_infos.size}, has text: #{txt_infos.size}"

    all_fpath = File.join(keep_dir, snvid + ".tsv")
    all_items = all_infos.values.sort_by(&.chidx)
    File.write(all_fpath, all_items.map(&.to_s).join("\n"))

    next if txt_infos.empty?
    txt_fpath = File.join(keep_dir, snvid + ".log")
    txt_items = txt_infos.values.sort_by(&.chidx)
    File.write(txt_fpath, txt_items.map(&.to_s).join("\n"))
  end
end
