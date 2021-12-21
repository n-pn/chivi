require "./../shared/seed_data"

module CV::FixBnames
  extend self

  DIR = "var/nvinfos/fixed"
  class_getter vtitles : TsvStore { TsvStore.new("#{DIR}/btitles_vi.tsv") }

  def fix_all!
    total, index = Nvinfo.query.count, 1
    query = Nvinfo.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |nvinfo|
      puts "- [fix_bnames] <#{index}/#{total}>".colorize.blue if index % 100 == 0
      fix_bname!(nvinfo)
      index += 1
    end
  end

  def fix_books!(titles : Array(String))
    titles.each do |title|
      query = Nvinfo.query.filter_btitle(title)
      query.each { |nvinfo| fix_bname!(nvinfo) }
    end
  end

  def fix_bname!(nvinfo : Nvinfo)
    zname, bhash = nvinfo.zname, nvinfo.bhash

    nvinfo.hname = BookUtils.hanviet(zname)
    hslug = BookUtils.scrub_vname(nvinfo.hname, "-")

    nvinfo.bslug = hslug.split("-").first(7).push(bhash[0..3]).join("-")
    nvinfo.hslug = "-#{hslug}-"

    vname = vtitles.fval(zname) || convert(zname, bhash)
    nvinfo.vname = TextUtils.titleize(vname)
    nvinfo.vslug = "-#{BookUtils.scrub_vname(vname, "-")}-"

    nvinfo.save!
  end

  PREFIXES = {
    "火影之" => "NARUTO: ",
    "民国之" => "Dân quốc: ",
    "三国之" => "Tam Quốc: ",
    "综漫之" => "Tổng mạn: ",
    "娱乐之" => "Giải trí: ",
    "重生之" => "Trùng sinh: ",
    "穿越之" => "Xuyên qua: ",
    "复活之" => "Phục sinh: ",
    "网游之" => "Game online: ",

    "哈利波特之" => "Harry Potter: ",
    "网游三国之" => "Tam Quốc game online: ",
  }

  def convert(zname : String, bhash : String)
    mtl = MtCore.generic_mtl(bhash)
    pre = ""

    PREFIXES.each do |key, val|
      next unless zname.starts_with?(key)
      pre, zname = val, zname.sub(/^#{key}/, "")
      break
    end

    pre + mtl.cv_plain(zname).to_s
  end
end

if ARGV.empty?
  CV::FixBnames.fix_all!
else
  CV::FixBnames.fix_books!(ARGV)
end
