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
      dnum: MT::MtDnum.from(d_id, 1_i8).to_i,
      rank: 2
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

Dir.glob(MT::SqDefn::DIR + "/*.*") { |file| File.delete?(file) }

INIT_DIR = "var/mtdic/seeds"

Dir.each_child(INIT_DIR) do |dname|
  next if dname.starts_with?('_')
  d_id = MT::MtDtyp.map_id(dname)

  MT::SqDefn.db(d_id).open_tx do |db|
    files = Dir.glob("#{INIT_DIR}/#{dname}/*.tab").sort!
    files.each do |file|
      defns = QtDefn.load_tsv(file)
      defns.each(&.to_sq(d_id).upsert!(db: db))
      puts "#{file}: #{defns.size}"
    end
  end
end

start = Time.monotonic
zterms = ZR_DB.query_all "select * from zvterm", as: MT::PgDefn

puts Time.monotonic - start
mdatas = zterms.map { |x| MT::SqDefn.new(x) }
puts Time.monotonic - start

mdatas.group_by { |x| x.d_id % 10 }.each do |group, items|
  MT::SqDefn.db(group).open_tx do |db|
    items.each(&.upsert!(db: db))
  end
  puts "#{group}: #{Time.monotonic - start}"
end

puts mdatas.size
