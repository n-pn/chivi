require "../data/v1_dict"
require "../core/m1_core"
require "./_m1_ctrl_base"

class M1::TranData
  CRIT_URL = "#{CV_ENV.ys_host}/_ys/crits"
  REPL_URL = "#{CV_ENV.ys_host}/_ys/repls"

  def self.load_cached(type : String, name : String, wn_id : Int32, format : String = "mtl")
    case type
    when "crits"
      input, wn_id = load_remote("#{CRIT_URL}/#{name}/ztext", wn_id)
    when "repls"
      input, wn_id = load_remote("#{REPL_URL}/ztext/#{name}", wn_id)
    when "posts"
      input = File.read("tmp/qtran/#{name}.txt")
    when "chaps"
      input = File.read("tmp/chaps/#{name}.txt")
    else
      raise "unsupported!"
    end

    new(input, wn_id, format)
  end

  def self.load_remote(href : String, wn_id : Int32)
    HTTP::Client.get(href) do |res|
      body = res.body_io.gets_to_end
      raise NotFound.new(body) unless res.status.success?

      input = body.tr("\t", " ")
      wn_id = res.headers["X-WN_ID"]?.try(&.to_i?) || wn_id

      {input, wn_id}
    end
  end

  getter input : String
  getter udict : DbDict

  def initialize(@input, @wn_id : Int32, format : String)
    @udict = DbDict.load(wn_id) rescue DbDict.load(0)
    @to_mtl = format == "mtl"
  end

  def cv_wrap(w_user : String = "", w_init : Bool = false, w_stat : Bool = true, &)
    engine = MtCore.init(@wn_id, user: w_user, init: w_init)

    String.build do |io|
      tspan = Time.measure { with self yield io, engine }
      tspan = tspan.total_milliseconds.round.to_i

      next unless w_stat
      io << "\n$\t$\t$\n"
      io << tspan << '\t' << @udict.term_avail << '\t' << @udict.dname
    end
  end

  def cv_post(io : IO, engine : MtCore)
    @input.each_line do |line|
      data = engine.cv_plain(line)
      @to_mtl ? data.to_mtl(io) : data.to_txt(io)
      io << '\n'
    end
  end

  def cv_chap(io : IO, engine : MtCore, w_title : Bool = true, label : String? = nil)
    # render title

    input = @input.each_line
    title = input.next

    return unless title.is_a?(String)

    data = w_title ? engine.cv_title(title) : engine.cv_plain(title)
    @to_mtl ? data.to_mtl(io) : data.to_txt(io)
    io << '\t' << ' ' << label if label
    io << '\n'

    input.each do |line|
      data = engine.cv_plain(line)
      @to_mtl ? data.to_mtl(io) : data.to_txt(io)
      io << '\n'
    end
  end
end
