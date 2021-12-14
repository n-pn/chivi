require "./../shared/seed_data"

module CV::FixBnames
  extend self

  DIR = "var/nvinfos/fixes"
  class_getter vtitles : TsvStore { TsvStore.new("#{DIR}/vi_btitles.tsv") }

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
    ztitle, bhash = nvinfo.ztitle, nvinfo.bhash

    nvinfo.htitle = BookUtils.hanviet(ztitle)
    htslug = BookUtils.scrub_vname(nvinfo.htitle, "-")

    nvinfo.bslug = htslug.split("-").first(7).push(bhash[0..3]).join("-")
    nvinfo.htslug = "-#{htslug}-"

    vtitle = vtitles.fval(ztitle) || convert(ztitle, bhash)
    nvinfo.vtitle = TextUtils.titleize(vtitle)
    nvinfo.vtslug = "-#{BookUtils.scrub_vname(vtitle, "-")}-"

    nvinfo.save!
  end

  def convert(ztitle : String, bhash : String)
    mtl = MtCore.generic_mtl(bhash)
    case ztitle
    when .starts_with?("重生之")
      ztitle = ztitle.sub(/^重生之/, "")
      "Trùng sinh: " + mtl.cv_plain(ztitle).to_s
    else
      mtl.cv_plain(ztitle).to_s
    end
  end
end

if ARGV.empty?
  CV::FixBnames.fix_all!
else
  CV::FixBnames.fix_books!(ARGV)
end
