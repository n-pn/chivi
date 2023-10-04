require "http/client"

struct RD::Chdata
  TXT_DIR = "var/texts"
  DB3_DIR = "var/stems"

  @base_path : String

  def initialize(spath : String)
    @base_path = "#{TXT_DIR}/#{spath}"
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
    "#{@base_path}.#{fkind}"
  end

  def read(fkind : String = "raw.txt")
    self.read_file(self.file_path(fkind))
  end

  def read(fkind : String = "raw.txt", &)
    self.read_file(file_path(fkind)) { |line| yield line }
  end

  def read_raw
    self.read_file(self.file_path("raw.txt"))
  end

  def read_raw(&)
    self.read_file(self.file_path("raw.txt")) { |line| yield line }
  end

  def read_mtl(m_alg : String, mtype : String)
    self.read_file(self.file_path("#{m_alg}.#{mtype}"))
  end

  def read_con(m_alg : String = "avail", force = false)
    is_existed = false

    mtl_1_path = self.file_path("hmes.con")
    mtl_2_path = self.file_path("hmeb.con")
    mtl_3_path = self.file_path("hmeg.con")

    case
    when m_alg == "mtl_1"
      con_path = mtl_1_path
    when m_alg == "mtl_2"
      con_path = mtl_2_path
    when m_alg == "mtl_3"
      con_path = mtl_3_path
    when File.file?(mtl_3_path) # mode == avail
      m_alg = "mtl_3"
      con_path = mtl_3_path
      is_existed = true
    when File.file?(mtl_2_path) # mode == avail
      m_alg = "mtl_2"
      con_path = mtl_2_path
      is_existed = true
    else
      m_alg = "mtl_1"
      con_path = mtl_1_path
    end

    if is_existed || File.file?(con_path)
      read_con_file(con_path, m_alg)
    elsif force
      call_hanlp_file_api(self.file_path("raw.txt"), con_path, m_alg)
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

    HTTP::Client.get(link) do |res|
      raise "error: #{res.body}" unless res.status.success?
      con_data = res.body_io.gets_to_end
      spawn File.write(con_path, con_data)
      {con_data.lines, m_alg}
    end
  end

  def save_raw!(ptext : String, title : String? = nil)
    # TODO: save to db3 file?
    File.open(self.file_path("raw.txt"), "w") do |file|
      file << title << '\n' if title
      file << ptext
    end
  end

  def self.read_raw(spath : String, ftype : Rdtype)
    new(spath, ftype).read_raw
  end

  def self.read_raw(spath : String)
    new(spath).read_raw
  end
end
