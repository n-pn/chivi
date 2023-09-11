require "./_mt_ctrl_base"

require "../data/vi_dict"
require "../data/vi_term"

class MT::ViDictCtrl < AC::Base
  base "/_ai/dicts"

  @[AC::Route::GET("/")]
  def index(dtype : ViDict::Dtype = ViDict::Dtype::None)
    pg_no, limit, offset = _paginate(min: 10, max: 100)

    total = ViDict.count(dtype)
    dicts = ViDict.get_all(dtype, limit, offset)
    dicts = dicts.sort_by! { |x| {x.dtype, -x.mtime} }

    output = {
      dicts: dicts,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: output
  end

  @[AC::Route::GET("/:dname")]
  def show(dname : String)
    dname = dname.sub(':', '/')

    vdict = ViDict.find(dname) || begin
      raise NotFound.new("từ điển không tồn tại") unless dname.starts_with?("book/")
      ViDict.new(dname, :book, dname, dname)
    end

    json = {
      dinfo: vdict,
      users: vdict.users.split(',', remove_empty: true),
      # terms: ViTerm.get_all(db: ViTerm.db(dname), &.<< "order by mtime limit 10"),
    }

    render json: json
  end
end
