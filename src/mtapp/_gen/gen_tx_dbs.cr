require "colorize"
require "../data/tx_term"

IDX_DIR = "var/anlzs/texsmart/idx"
INP_DIR = "var/anlzs/texsmart/tmp"

books = Dir.children(INP_DIR).reject!(&.starts_with?('!'))

books.each do |bname|
  extract(bname)
end

def extract(bname : String)
  dir_path = "#{INP_DIR}/#{bname}"
  puts dir_path.colorize.yellow

  wn_id = bname.split('-').first

  db = MT::TxTerm.open_db(wn_id)
  db.exec "begin"

  word_size = save_terms(db, dir_path, 111)
  phrase_size = save_terms(db, dir_path, 211)

  save_entities(db, dir_path, {word_size, phrase_size}.min, 312)

  db.exec "commit"
  db.close
end

TYPE_GLOBS = {
  111 => "*.word_log\\[M\\].tsv",
  121 => "*.word_log\\[L\\].tsv",
  122 => "*.word_crf\\[L\\].tsv",
  123 => "*.word_dnn\\[L\\].tsv",
  #
  211 => "*.phrase_log\\[M\\].tsv",
  221 => "*.phrase_log\\[L\\].tsv",
  222 => "*.phrase_crf\\[L\\].tsv",
  223 => "*.phrase_dnn\\[L\\].tsv",
  #
  311 => "*.entity_coarse\\[M\\].{tsv,ner}",
  312 => "*.entity_fine\\[M\\].{tsv,ner}",
  322 => "*.entity_fine\\[L\\].{tsv,ner}",
  323 => "*.entity_acc\\[L\\].{tsv,ner}",
}

def save_terms(db, dir_path : String, type : Int32)
  output = Hash({String, String}, Int32).new(0)
  wcount = 0_i64

  type_glob = TYPE_GLOBS[type]
  files = Dir.glob(File.join(dir_path, type_glob))

  puts "- [#{type_glob}], files: #{files.size}".colorize.cyan

  files.each do |file|
    File.each_line(file) do |line|
      rows = line.split('\t')
      next if rows.size < 2

      zstr, ztag = rows

      output[{zstr, ztag}] += 1
      wcount &+= zstr.size
    end
  end

  output.each do |(zstr, ztag), count|
    mrate = (wcount * count) // 1_000_000
    MT::TxTerm.upsert(zstr, type, ztag, count, mrate.to_i, db)
  end

  wcount
end

def save_entities(db, dir_path : String, wcount : Int64, type : Int32) : Nil
  output = Hash({String, String}, Int32).new(0)

  type_glob = TYPE_GLOBS[type]
  files = Dir.glob(File.join(dir_path, type_glob))

  puts "- [#{type_glob}], files: #{files.size}".colorize.cyan

  files.each do |file|
    File.each_line(file) do |line|
      rows = line.split('\t')
      next if rows.size < 3

      zstr, _, ztag = rows
      output[{zstr, ztag}] += 1
    end
  end

  output.each do |(zstr, ztag), count|
    mrate = (wcount * count) // 1_000_000
    MT::TxTerm.upsert(zstr, type, ztag, count, mrate.to_i, db)
  end
end
