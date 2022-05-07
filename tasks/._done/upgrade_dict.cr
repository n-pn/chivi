require "../src/libcv/vp_dict"

MAIN_DIR = "_db/vpdict/main"
PLEB_DIR = "_db/vpdict/pleb"

def upgrade_base(dname : String, book = false)
  input = CV::VpDict.load(dname, "_base", reset: true)

  dpath = book ? "books/#{dname}.tsv" : "#{dname}.tsv"
  input.load!("#{MAIN_DIR}/#{dpath}")

  input.save! unless input.data.size == 0
end

def upgrade_uniq(dname : String, book = false)
  dpath = book ? "books/#{dname}.tsv" : "#{dname}.tsv"
  input = CV::VpDict.new("#{PLEB_DIR}/#{dpath}", dtype: 2)
  return if input.data.size == 0

  output = {} of String => CV::VpDict
  input.data.each do |term|
    next if term._flag == 2 || term.uname == "~"
    vpdict = output[dname + "/" + term.uname] ||= CV::VpDict.load(dname, term.uname)

    vpdict.set(vpdict.new_term(term))
  end
  output.each_value(&.save!)
end

puts "- upgrade main:"

upgrade_base("regular")
upgrade_base("hanviet")
upgrade_base("suggest")
upgrade_base("combine")

Dir.glob("#{MAIN_DIR}/books/*.tsv").each do |file|
  dname = File.basename(file, ".tsv")
  upgrade_base(dname, book: true) unless dname == "combine"
end

puts "- upgrade uniq:"

upgrade_uniq("regular")

Dir.glob("#{PLEB_DIR}/books/*.tsv").each do |file|
  dname = File.basename(file, ".tsv")
  next if dname.includes?(".")
  upgrade_uniq(dname, book: true) unless dname == "combine"
end
