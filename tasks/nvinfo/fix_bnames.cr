require "./../shared/seed_data"

module CV::FixBnames
  extend self

  DIR = "var/fixtures"
  class_getter vtitles : TsvStore { TsvStore.new("#{DIR}/vi_bitles.tsv") }

  def set!
    total, index = Cvbook.query.count, 0
    query = Cvbook.query.order_by(weight: :desc)
    query.each_with_cursor(20) do |cvbook|
      index += 1
      if index % 100 == 0
        puts "- [fix_bnames] <#{index}/#{total}>".colorize.blue
      end

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
  end

  def convert(ztitle : String, bhash : String)
    mtl = MtCore.generic_mtl(bhash)
    mtl.cv_plain(ztitle).to_s
  end
end

CV::FixBnames.set!
