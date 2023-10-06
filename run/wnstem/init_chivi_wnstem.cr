ENV["CV_ENV"] = "production"
require "../../src/wnapp/data/wnstem"
require "../../src/wnapp/data/chinfo"

QUERY = WN::Wnstem.schema.upsert_stmt(keep_fields: %w[chap_total chap_avail rlink rtime])

CHIVI = WN::Wnstem.all_by_sname("~chivi").to_h { |x| {x.wn_id, x} }

def transfer(sname : String)
  stems = WN::Wnstem.all_by_sname(sname)

  stems.each do |origin|
    if target = CHIVI[origin.wn_id]?
      next if target.chap_total > 0
    else
      target = WN::Wnstem.new(origin.wn_id, "~chivi")
    end

    chinfos = WN::Chinfo.get_all(db: origin.chap_list)

    puts "copy from #{origin.id} to #{target.id}, chapters: #{chinfos.size}"

    target.chap_list.open_tx do |db|
      chinfos.each do |chinfo|
        chinfo.spath = "#{origin.sname}/#{origin.s_bid}/#{chinfo.ch_no}" if chinfo.spath.empty?
        chinfo.upsert!(db: db)
      end
    end

    target.chap_total = origin.chap_total
    target.chap_avail = origin.chap_avail
    target.rlink = origin.rlink
    target.rtime = origin.rtime

    target.upsert!(query: QUERY)
  end
end

snames = ARGV.reject(&.starts_with?('-'))
snames.each { |sname| transfer(sname) }
