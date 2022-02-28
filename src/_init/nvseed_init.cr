require "json"

class CV::NvseedInit
  INP_DIR = "_db/.cache/%s/infos"
  OUT_DIR = "db/seed_data/nvseeds/%s"

  def self.inp_path(sname : String, snvid : String, mulu = false)
    File.join(INP_DIR % sname, "#{snvid}.html.gz")
  end

  def self.out_path(sname : String, snvid : String)
    File.join(OUT_DIR % sname, "#{snvid}.json")
  end

  def self.load(sname : String, snvid : String, mode = 0, lbl = "1/1")
    inp_file = self.inp_path(sname, snvid)
    inp_time = FileUtil.mtime_int(inp_file)

    out_file = self.out_path(sname, snvid)
    out_time = FileUtil.mtime_int(out_file)

    if (mode == 2 && inp_time > 0) || (inp_time > out_time)
      parser = self.get_parser(sname, snvid, lbl: lbl)
      self.new(sname, snvid, parser).tap(&.save!)
    elsif mode == 1 && out_time > 0
      self.from_json(File.read(out_file))
    else
      nil
    end
  end

  def self.get_parser(sname : String, snvid : String, lbl = "1/1")
    remote = RemoteInfo.new(sname, snvid, lbl: lbl)
    parser = remote.get_parser(full: true)
  end

  ####################

  include JSON::Serializable

  getter sname = ""
  getter snvid = ""

  property btitle = ""
  property author = ""

  getter bcover = ""
  getter bintro = [] of String
  getter genres = [] of String

  getter status_int = 0
  getter status_str = ""

  getter update_str = ""
  getter update_int = 0_i64

  getter last_snvid = ""
  getter chap_count = 0_i64

  def initialize(@sname, @snvid)
  end

  FIELDS = {
    :btitle, :author,
    :genres, :bintro, :bcover,
    :status_str, :update_str, :last_snvid,
  }

  def initialize(@sname : String, @snvid : String, parser : RmInfoGeneric)
    {% for field in FIELDS %}
      @{{field.id}} = parser.{{field.id}}
    {% end %}

    @status_int = parser.status_int(@status_str)
    @update_int = parser.updated_at(@update_str).to_unix
  end

  def save!
    out_file = NvseedInit.out_path(@sname, @snvid)
    FileUtils.mkdir_p(File.dirname(out_file))
    File.write(out_file, self.to_pretty_json)
  end

  ######################
end
