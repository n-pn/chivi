require "http/client"

struct RD::Chpart
  TXT_DIR = "var/texts"

  @cpath : String

  def initialize(cpath : String)
    @cpath = "#{TXT_DIR}/#{cpath}"
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
    "#{@cpath}.#{fkind}"
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

  def read_con(m_alg : String = "mtl_1", force = false)
    case
    when m_alg == "mtl_3"
      con_path = self.file_path("hmeg.con")
    when m_alg == "mtl_2"
      con_path = self.file_path("hmeb.con")
    else
      con_path = self.file_path("hmes.con")
      m_alg = "mtl_1"
    end

    if File.info?(con_path).try(&.size.> 0)
      read_con_file(con_path, m_alg)
    elsif force
      call_hanlp_file_api(self.file_path("raw.txt"), con_path, m_alg)
    else
      raise "404"
    end
  end

  @[AlwaysInline]
  private def read_con_file(con_path : String, m_alg : String)
    {self.read_file(con_path), m_alg}
  end

  def call_hanlp_file_api(txt_path : String, con_path : String, m_alg : String)
    txt_data = File.read(txt_path)
    txt_path = URI.encode_path_segment(txt_path)
    link = "#{CV_ENV.lp_host}/mtl_file/#{m_alg}?file=#{txt_path}"

    HTTP::Client.get(link, body: txt_data) do |res|
      con_data = res.body_io.gets_to_end
      raise "error: [#{con_data}] for #{txt_path}" unless res.status.success?

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

  def self.read_raw(spath : String, &)
    new(spath).read_raw { |line| yield line }
  end
end
