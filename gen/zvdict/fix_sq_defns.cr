ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/mt_ai/data/pg_defn"
require "../../src/mt_ai/data/sq_defn"

record QtDefn, zstr : String, cpos : String, vstr : String, attr : String do
  def initialize(cols : Array(String))
    @zstr, @cpos, @vstr = cols
    @attr = cols[3]? || ""
  end

  def to_sq(d_id : Int32)
    MT::SqDefn.new(
      d_id: d_id, zstr: @zstr, vstr: @vstr,
      epos: MT::MtEpos.parse(@cpos).to_i,
      attr: MT::MtAttr.parse_list(@attr).to_i,
      dnum: MT::MtDnum.from(d_id, 2_i8).to_i
    )
  end

  def self.load_tsv(tsv_path : String)
    output = [] of self
    File.each_line(tsv_path, chomp: true) do |line|
      output << new(line.split('\t')) unless line.blank?
    end
    output
  end
end

INIT_DIR = "/srv/chivi/mtdic/seeds"

Dir.each_child(INIT_DIR) do |dname|
  d_id = MT::MtDtyp.map_id(dname)

  MT::SqDefn.db(d_id).open_tx do |db|
    files = Dir.glob("#{INIT_DIR}/#{dname}/*.tsv").sort!
    files.each do |file|
      defns = QtDefn.load_tsv(file)
      defns.each(&.to_sq(d_id).upsert!(db: db))
      puts "#{file}: #{defns.size}"
    end
  end
end
