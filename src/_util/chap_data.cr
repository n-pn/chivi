require "http/client"

struct ChapData
  enum Ftype : Int8
    NC; UP; RM
  end

  WN_DIR = "var/wnapp/chtext"

  UP_DIR = "var/up_db/texts"
  RM_DIR = "var/rm_db/texts"

  def self.new(fpath : String, ftype : String)
    new(fpath, Ftype.parse(ftype))
  end

  def initialize(fpath : String, @ftype : Ftype = :nc)
    case ftype
    in .nc? then @spath = "#{WN_DIR}/#{fpath}"
    in .up? then @spath = "#{UP_DIR}/#{fpath}"
    in .rm? then @spath = "#{RM_DIR}/#{fpath}"
    end
  end

  private def read_file(fpath : String, &)
    File.each_line(fpath, chomp: true) { |line| yield line }
  end

  @[AlwaysInline]
  private def read_file(fpath : String)
    File.read_lines(fpath, chomp: true)
  end

  @[AlwaysInline]
  def file_path(fkind : String)
    "#{@spath}.#{fkind}"
  end

  @[AlwaysInline]
  def raw_file_path
    self.file_path(@ftype.nc? ? "txt" : "raw.txt")
  end

  @[AlwaysInline]
  def mtl_file_path(fkind : String)
    self.file_path(fkind).sub("chtext", "nlp_wn")
  end

  @[AlwaysInline]
  def vtl_file_path(fkind : String)
    fpath = self.file_path(fkind)
    @ftype.nc? ? fpath.sub("chtext", "chtran") : fpath
  end

  def read(fkind : String = "raw.txt")
    self.read_file(self.file_path(fkind))
  end

  def read(fkind : String = "raw.txt", &)
    self.read_file(file_path(fkind)) { |line| yield line }
  end

  def read_raw
    self.read_file(self.raw_file_path)
  end

  def read_raw(&)
    self.read_file(self.raw_file_path) { |line| yield line }
  end

  def read_mtl(m_alg : String, mtype : String)
    fpath = self.file_path("#{m_alg}.#{mtype}")
    fpath = fpath.sub("chinfo", "nlp_wn") if @ftype.nc?
    self.read_file(fpath)
  end

  def read_con(m_alg : String = "avail", force = false)
    is_existed = false

    mtl_1_path = self.mtl_file_path("hmes.con")
    mtl_2_path = self.mtl_file_path("hmeb.con")
    mtl_3_path = self.mtl_file_path("hmeg.con")

    case
    when m_alg == "mtl_1"
      con_path = mtl_1_path
    when m_alg == "mtl_2"
      con_path = mtl_2_path
    when m_alg == "mtl_3"
      con_path = mtl_3_path
    when File.file?(mtl_1_path) # mode == avail
      m_alg = "mtl_1"
      con_path = mtl_1_path
      is_existed = true
    when File.file?(mtl_2_path) # mode == avail
      m_alg = "mtl_2"
      con_path = mtl_2_path
      is_existed = true
    when File.file?(mtl_3_path) # mode == avail
      m_alg = "mtl_3"
      con_path = mtl_3_path
      is_existed = true
    else
      m_alg = "mtl_1"
      con_path = mtl_1_path
    end

    if is_existed || File.file?(con_path)
      return read_con_file(con_path, m_alg)
    elsif force
      call_hanlp_file_api(self.raw_file_path, con_path, m_alg)
    else
      raise "data not parsed!"
    end
  end

  @[AlwaysInline]
  private def read_con_file(con_path : String, m_alg : String)
    {self.read_file(con_path), m_alg}
  end

  def call_hanlp_file_api(txt_path : String, con_path : String, m_alg : String)
    link = "#{CV_ENV.lp_host}/mtl_file/#{m_alg}?file=#{txt_path}"
    Dir.mkdir_p(File.dirname(con_path)) if @ftype.nc?

    HTTP::Client.get(link) do |res|
      raise "error: #{res.body}" unless res.status.success?
      con_data = res.body_io.gets_to_end
      spawn File.write(con_path, con_data)
      {con_data.lines, m_alg}
    end
  end
end
