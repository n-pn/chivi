require "../zroot/rmbook"

DIR = "var/.keep/rmbook"

def init(hostname : String)
  rmconf = Rmconf.from_host!(hostname)
  sname = rmconf.seedname

  files = Dir.glob("#{DIR}/#{hostname}/*.htm")
  files.reject!(&.ends_with?("-cata.htm"))
  files.sort_by! { |f| File.basename(f, ".htm").to_i? || 0 }

  db = ZR::Rmbook.db(sname)

  files.each do |file|
    entry = ZR::Rmbook.from_html_file(file, sname: sname)
    entry.upsert!(db)
    puts "- [#{sname}/#{entry.id}]: #{entry.btitle.colorize.green} updated"
  rescue ex
    puts [file, ex.message].colorize.red
  end
end

ARGV.each do |hostname|
  init(hostname)
end
