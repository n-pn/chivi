require "http/client"
require "../_ctrl_base"

class CV::DlTranCtrl < CV::BaseCtrl
  base "/_db/dlcvs"

  @[AC::Route::GET("/")]
  def index(wn_id : Int32? = nil, sname : Int32? = nil, _flag : Int32? = nil)
    pg_no, limit, offset = _paginate(min: 5)

    args = [_uname] of DB::Any

    query = String.build do |sql|
      sql << "select * from dltrans"
      sql << " where uname = ?"

      if _flag
        sql << " and _flag = ?"
        args << _flag
      end

      if wn_id
        sql << " and wn_id = ?"
        args << wn_id
      end

      if sname
        sql << " and sname = ?"
        args << sname
      end

      sql << " order by id desc"
      sql << " limit ? offset ?"
      args << limit << offset
    end

    render json: {
      items: DlTran.repo.open_db(&.query_all(query, args: args, as: DlTran)),
      pg_no: pg_no,
    }
  end

  struct DlForm
    include JSON::Serializable

    getter wn_id : Int32
    getter sname : String

    getter from : Int32
    getter upto : Int32

    getter texsmart_pos : Bool = false
    getter texsmart_ner : Bool = false

    getter mt_version : Int32 = 1

    @[JSON::Field(ignore: true)]
    getter s_bid : Int32 = -1

    @[JSON::Field(ignore: true)]
    getter word_count : Int32 = -1

    def after_initialize
      @upto = @from if @upto < @from

      url = "localhost:5020/_wn/seeds/#{@wn_id}/#{@sname}?from=#{@from}&upto=#{@upto}"

      HTTP::Client.get(url) do |res|
        raise "error" unless res.status.success?

        data = JsonData.from_json(res.body_io)
        @s_bid = data.s_bid
        @word_count = data.word_count
      end
    end

    record JsonData, s_bid : Int32, word_count : Int32 do
      include JSON::Serializable
    end

    def record(uname : String, privi : Int32)
      DlTran.new(
        @wn_id, @sname, @s_bid, @from, @upto,
        @texsmart_pos, @texsmart_ner,
        @mt_version, self.word_count,
        uname: uname, privi: privi, _flag: 0
      )
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def create(form : DlForm)
    guard_privi 1, "tải xuống bản dịch"

    vcoin_remain = _viuser.vcoin - (form.word_count / 100_000).round(2)

    if vcoin_remain < 0
      raise BadRequest.new("Số lượng vcoin tối thiểu không đủ để tải bản dịch!")
    end

    Clear::SQL.transaction do
      dltran = form.record(_viuser.uname, _viuser.privi)
      _viuser.update!(vcoin: vcoin_remain)
      dltran.save!
    end

    spawn do
      invoke_translation!(force: false)
    end

    render json: {msg: "ok"}
  end

  private def invoke_translation!(force : Bool = false)
    args = {"-f"} if force
    status = Process.run("./bin/mass_convert", args: args)
    invoke_translation!(force: true) unless status.success?
  end

  @[AC::Route::GET("/:id")]
  def download(id : Int32)
    file_path = "var/texts/dlcvs/#{_uname}/#{id}.txt"
    raise BadRequest.new("Dữ liệu không tồn tại") unless File.file?(file_path)

    render text: File.read(file_path)
  end
end
