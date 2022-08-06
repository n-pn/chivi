require "colorize"
require "file_utils"
require "compress/zip"

require "../shared/bootstrap"
require "../../src/appcv/nvchap/*"

INP_DIR = Path["var", "chtexts"]

NAME_MAP = load_map Path["var", "fixed", "books.tsv"]

def load_map(path : String | Path)
  File.read_lines(path).each_with_object({} of Int32 => String) do |line, hash|
    cols = line.split('\t')
    next if cols.size < 2
    hash[cols[1].to_i] = cols[0]
  end
end

Dir.children(INP_DIR).each do |sname|
  next unless sname == "miscs" # sname.starts_with?('@')
  sname_dir = INP_DIR.join(sname)

  Dir.children(sname_dir).each do |s_bid|
    book_dir = sname_dir.join(s_bid)
    update(sname, s_bid, book_dir)
  end
end

def update(sname, s_bid, book_dir)
  unless bhash = NAME_MAP[s_bid.to_i]?
    return puts "missing: #{sname}/#{s_bid}"
  end

  unless nvinfo = CV::Nvinfo.find({bhash: bhash})
    return puts "missing: #{sname}/#{s_bid}/#{bhash}"
  end

  chroot = CV::Chroot.load!(nvinfo, sname, force: true)

  infos = [] of CV::Chinfo

  Dir.glob(book_dir.join("*.tsv")).each do |file|
    File.read_lines(file).each do |line|
      next if line.empty?

      cols = line.split('\t')
      next if cols.size < 3

      infos << CV::Chinfo.new(chroot, cols)
    rescue err
      puts [line, err].colorize.red
    end
  end

  puts "- #{sname}/#{s_bid}: #{infos.size} updated"
  CV::Chinfo.bulk_upsert(infos)
end
