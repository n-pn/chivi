require "../src/wnapp/data/chtext"

def convert(wnstem : WN::Wnsterm)
  chlist = WN::Chinfo.get_all(db: wnstem.chap_list)
  puts "#{wnstem.sname} #{wnstem.s_bid}: chlist.size"

  chlist.each do |chinfo|
    chtext = WN::Chtext.new(wnstem, chinfo)

    wn_path = chtext.wn_path(0)
    zh_path = chtext.zh_path

    next if !chinfo.cksum.empty? && File.exists?(wn_path) && File.exists?(zh_path)

    if cksum = chtext.import_existing!
      puts "#{chinfo.ch_no}-#{cksum} persisted!"
    else
      puts "#{chinfo.ch_no} missing".colorize.red
    end
  end
end

def convert(sname : String)
  stems = WN::Wnsterm.get_all(sname, &.<< "where sname = $1")
  stems.each { |stem| convert(stem) }
end

snames = ARGV.reject(&.starts_with?('-'))
snames.each { |sname| convert sname }
