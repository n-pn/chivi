require "./../shared/seed_data"

module CV::FixBnames
  extend self

  DIR = "var/fixtures"
  class_getter vtitles : TsvStore { TsvStore.new("#{DIR}/vi_btitles.tsv") }

  def fix_all!
    total, index = Cvbook.query.count, 1
    query = Cvbook.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |cvbook|
      puts "- [fix_bnames] <#{index}/#{total}>".colorize.blue if index % 100 == 0
      fix_bname!(cvbook)
      index += 1
    end
  end

  def fix_books!(titles : Array(String))
    titles.each do |title|
      query = Cvbook.query.filter_btitle(title)
      query.each { |cvbook| fix_bname!(cvbook) }
    end
  end

  def fix_bname!(cvbook : Cvbook)
    ztitle, bhash = cvbook.ztitle, cvbook.bhash

    cvbook.htitle = BookUtils.hanviet(ztitle)
    htslug = BookUtils.scrub_vname(cvbook.htitle, "-")

    cvbook.bslug = htslug.split("-").first(7).push(bhash[0..3]).join("-")
    cvbook.htslug = "-#{htslug}-"

    vtitle = vtitles.fval(ztitle) || convert(ztitle, bhash)
    cvbook.vtitle = TextUtils.titleize(vtitle)
    cvbook.vtslug = "-#{BookUtils.scrub_vname(vtitle, "-")}-"

    cvbook.save!
  end

  def convert(ztitle : String, bhash : String)
    mtl = MtCore.generic_mtl(bhash)
    case ztitle
    when .starts_with?("重生之")
      ztitle = ztitle.sub(/^重生之/, "")
      "Sống lại: " + mtl.cv_plain(ztitle).to_s
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
