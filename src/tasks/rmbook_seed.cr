require "../zroot/rmbook"
require "../_data/wnovel/wninfo"

# require "../_data/wnovel/wnlink"
# require "../mt_v1/data/v1_dict"

EXISTED = {} of String => Set(String)

PGDB.query_each "select author_zh, btitle_zh from wninfos" do |rs|
  author, btitle = rs.read(String, String)
  set = EXISTED[author.downcase] ||= Set(String).new
  set << btitle.downcase
end

FULL_TRUSTED = {"!hetushu", "!rengshu", "!zxcs_me", "!wenku8"}

MATCH_AUTHOR = {
  "!xklxsw",
  "!69shu",
  "!133txt",
  "!ptwxz",
  "!shubaow",
  "!uukanshu",
  "!uukanshu_tw",
  "!uuks_org",
  "!xbiquge",
  "!ymxwx",
  "!tasim",
  "!zsdade",
  "!os2022",
  "!madcowww",
  "!egyguard",
}

def should_seed?(sname : String, author : String, btitle : String)
  return true if sname.in?(FULL_TRUSTED)
  return false unless btitles = EXISTED[author.downcase]?
  btitles.includes?(btitle.downcase) || sname.in?(MATCH_AUTHOR)
end

def seed_book(sname : String)
  fake_rating = sname.in?("!hetushu", "!zxcs_me")

  rm_db = ZR::Rmbook.db(sname)
  rconf = Rmconf.load!(sname)

  inputs = ZR::Rmbook.get_all(db: rm_db, &.<< "where btitle <> ''")
  inputs.sort_by! { |x| x.id.to_i? || 0 } if inputs.first.id.to_i?

  inputs.each_slice(200).with_index(1) do |slice, block|
    puts "- [#{sname}] block: #{block}, books: #{slice.size}"

    PGDB.exec "begin"

    outputs = inputs.compact_map do |input|
      author, btitle = BookUtil.fix_names(author: input.author, btitle: input.btitle)
      next unless should_seed?(sname, author, btitle)

      wninfo = CV::Wninfo.upsert!(author_zh: author, btitle_zh: btitle, name_fixed: true)
      input.update_wninfo(wninfo, fake_rating: fake_rating)

      rlink = rconf.full_book_link(input.id)

      PGDB.exec <<-SQL, wninfo.id, sname, input.id, input.chap_count, rlink, input.rtime
        insert into wnseeds(wn_id, sname, s_bid, chap_total, rlink, rtime)
        values ($1, $2, $3, $4, $5, $6)
        on conflict (wn_id, sname) do update set
          s_bid = excluded.s_bid,
          chap_total = excluded.chap_total,
          rlink = excluded.rlink,
          rtime = excluded.rtime
        where wnseeds.chap_total <= excluded.chap_total
      SQL

      {input.id, wninfo.id, wninfo.bslug, wninfo.btitle_vi}
    end

    PGDB.exec "commit"

    rm_db.open_tx do |db|
      outputs.each do |yn_id, wn_id, _bslug, _vname|
        db.exec("update rmbooks set wn_id = $1 where id = $2", wn_id, yn_id) rescue nil
      end
    end
  end
end

snames = ARGV
snames = ["!hetushu"] if snames.empty?

snames.each do |sname|
  seed_book(sname)
end
