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
    File.read(self.file_path("raw.txt"))
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

  def self.read_raw(spath : String, cksum : String, psize : Int32)
    return "" if cksum.empty?

    String.build do |io|
      1.upto(psize) do |p_idx|
        fpath = "#{TEXT_DIR}/#{spath}-#{cksum}-#{p_idx}.raw.txt"
        lines = File.read_lines(fpath, chomp: true)
        lines.shift if p_idx > 1
        lines.each { |line| io << line << '\n' }
      end
    end
  rescue
    ""
  end
end
