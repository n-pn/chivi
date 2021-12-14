module CV
  extend self

  TIME_MIN = Time.utc(2010, 1, 1, 0, 0, 0).to_unix

  def upsert_nvinfo(cvbook : Cvbook)
    nvinfo = Nvinfo.find({id: cvbook.id}) || Nvinfo.new({id: cvbook.id})

    nvinfo.author_id = cvbook.author_id
    nvinfo.genre_ids = cvbook.bgenre_ids
    nvinfo.zseed_ids = cvbook.zhbooks.map { |x| NvSeed.map_id(x.sname) }.uniq

    nvinfo.bhash = cvbook.bhash
    nvinfo.bslug = cvbook.bslug

    nvinfo.zname = cvbook.ztitle
    nvinfo.hname = cvbook.htitle
    nvinfo.vname = cvbook.vtitle
    nvinfo.hslug = cvbook.htslug
    nvinfo.vslug = cvbook.vtslug

    nvinfo.cover = cvbook.bcover
    nvinfo.intro = cvbook.bintro

    nvinfo.status = cvbook.status
    nvinfo.shield = cvbook.shield

    nvinfo.atime = cvbook.bumped
    nvinfo.utime = cvbook.mftime

    nvinfo.created_at = cvbook.created_at
    nvinfo.updated_at = cvbook.updated_at

    if ysbook = cvbook.ysbooks.to_a.sort_by(&.voters.-).first?
      nvinfo.ys_snvid = ysbook.id
      nvinfo.ys_utime = ysbook.mftime < TIME_MIN ? TIME_MIN : ysbook.mftime

      nvinfo.pub_link = ysbook.root_link
      nvinfo.pub_name = ysbook.root_name

      nvinfo.yslist_count = ysbook.list_count
      nvinfo.yscrit_count = ysbook.crit_count

      nvinfo.set_ys_scores(ysbook.voters, ysbook.rating)
    end

    nvinfo.save!
  end

  Cvbook.query.order_by(id: :asc).each_with_cursor(20) do |cvbook|
    upsert_nvinfo(cvbook)
  end
end
