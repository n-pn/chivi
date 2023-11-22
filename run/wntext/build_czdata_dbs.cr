require "../../src/rdapp/data/chrepo"

STEM_DIR = "/2tb/var.chivi/stems"
TEXT_DIR = "/2tb/var.chivi/texts"

def import(sname : String, sn_id : String, uname : String)
  count = RD::Chrepo.new("#{sname}/#{sn_id}").init_text_db!(uname)
  puts "#{sname}/#{sn_id}: #{count} entries saved!"
end

snames = ARGV.reject!(&.starts_with?('-'))
# snames = ["rm!69shuba.com"] if snames.empty?

snames.each do |sname|
  cinfos = Dir.glob("#{STEM_DIR}/#{sname}/*-cinfo.db3")
  uname = sname.sub(/^rm|up/, "")

  # exists = Dir.glob("#{STEM_DIR}/rm#{sname}/*-zdata.db3").to_set

  cinfos.each do |fpath|
    # next if exists.includes?(fpath.sub("cinfo", "zdata"))
    sn_id = File.basename(fpath, "-cinfo.db3")
    import(sname, sn_id, uname)
  rescue ex
    puts [fpath, ex]
  end
end
