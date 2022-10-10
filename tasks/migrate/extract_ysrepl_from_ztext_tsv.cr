require "../../src/ysapp/inputs/raw_crit"

def read_book_id_map(file : String)
  File.read_lines(file).each_with_object({} of String => String) do |line, hash|
    cols = line.split('\t')
    next unless cols.size > 2
    uuid, book_id = cols

    hash[uuid] = book_id
  end
end

def save_crit_body(file : String)
  book_ids = read_book_id_map(file.sub("ztext", "infos"))

  File.read_lines(file).each do |line|
    cols = line.split('\t')
    next unless cols.size > 1

    # extract review uuid
    uuid = cols.shift

    # skip if content is hidden in yousuu
    next if cols.first == "$$$"

    raise "mising book_id for #{uuid}" unless book_id = book_ids[uuid]

    save_dir = "var/ys_db/crits/#{book_id}-zh"
    Dir.mkdir_p(save_dir)

    text_path = "#{save_dir}/#{uuid}.txt"
    return if File.exists?(text_path)

    File.write(text_path, cols.join('\n'))
  end
end

files = Dir.glob("var/ysinfos/yscrits/*-ztext.tsv")
files.each do |file|
  puts file
  save_crit_body(file)
rescue err
  puts file, err
end
