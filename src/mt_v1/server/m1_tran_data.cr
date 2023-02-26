require "../data/v1_dict"
require "../core/m1_core"

class M1::TranData
  CRIT_URL = "localhost:5400/_ys/crits"
  REPL_URL = "localhost:5400/_ys/repls"

  def self.load_cached(type : String, name : String, wn_id : Int32, format : String = "mtl")
    case type
    when "crits"
      lines, wn_id = load_remote("#{CRIT_URL}/#{name}/ztext", wn_id)
    when "repls"
      lines, wn_id = load_remote("#{REPL_URL}/#{name}/ztext", wn_id)
    when "posts"
      lines = File.read_lines("tmp/qtran/#{name}.txt")
    else
      raise "unsupported!"
    end

    new(lines, wn_id, format)
  end

  def self.load_remote(href : String, wn_id : Int32)
    HTTP::Client.get(href) do |res|
      body = res.body_io.gets_to_end
      raise NotFound.new(body) unless res.status.success?

      lines = body.tr("\t", " ").lines.map!(&.strip).reject!(&.empty?)
      wn_id = res.headers["X-WN_ID"]?.try(&.to_i?) || wn_id

      {lines, wn_id}
    end
  end

  getter lines : Array(String)
  getter udict : DbDict

  def initialize(@lines : Array(String), @wn_id : Int32, format : String)
    @udict = DbDict.load(wn_id) rescue DbDict.load(0)
    @to_mtl = format == "mtl"
  end

  def cv_wrap(w_user : String = "",
              w_temp : Bool = false,
              w_init : Bool = false,
              w_stat : Bool = true,
              &)
    engine = MtCore.init(@wn_id, user: w_user, temp: w_temp, init: w_init)

    String.build do |io|
      tspan = Time.measure { with self yield io, engine }
      tspan = tspan.total_milliseconds.round.to_i

      next unless w_stat
      io << "\n$\t$\t$\n"
      io << tspan << '\t' << @udict.term_avail << '\t' << @udict.dname
    end
  end

  def cv_post(io : IO, engine : MtCore)
    @lines.each do |line|
      data = engine.cv_plain(line)
      @to_mtl ? data.to_mtl(io) : data.to_txt(io)
      io << '\n'
    end
  end

  def cv_chap(io : IO, engine : MtCore, w_title : Bool = true, label : String? = nil)
    # render title

    title = @lines.first
    data = w_title ? engine.cv_title(title) : engine.cv_plain(title)
    @to_mtl ? data.to_mtl(io) : data.to_txt(io)
    io << '\t' << ' ' << label if label
    io << '\n'

    # render body

    1.upto(lines.size - 1) do |i|
      line = @lines.unsafe_fetch(i)
      data = engine.cv_plain(line)
      @to_mtl ? data.to_mtl(io) : data.to_txt(io)
      io << '\n'
    end
  end
end
