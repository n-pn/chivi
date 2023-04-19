require "../../src/ysapp/models/_base"
require "../../src/mt_v1/core/m1_core"

DICT_MAP = {} of Int32 => Int32

TXT_DIR = "var/ysapp/crits-txt"
TMP_DIR = "var/ysapp/crits-idx"

dict_sql = "select id::int, nvinfo_id::int from ysbooks order by voters desc"
PG_DB.query_each dict_sql do |rs|
  DICT_MAP[rs.read(Int32)] = rs.read(Int32)
end

crit_sql = "select yc_id from yscrits where ysbook_id = $1"

progress = 0

DICT_MAP.each do |y_bid, wn_id|
  progress += 1
  PG_DB.exec "update yscrits set nvinfo_id = $1 where ysbook_id = $2", wn_id, y_bid

  cv_mt = M1::MtCore.init(udic: wn_id)
  puts "- <#{progress}/#{DICT_MAP.size}> #{wn_id}".colorize.blue

  PG_DB.query_each(crit_sql, y_bid) do |rs|
    yc_id = rs.read(String)
    group = yc_id[0..3]

    inp_path = "#{TXT_DIR}/#{group}-zh/#{yc_id}.txt"
    next unless File.file?(inp_path)

    out_dir = "#{TXT_DIR}/#{group}-vi"
    Dir.mkdir_p(out_dir)

    begin
      vhtml = convert(cv_mt, inp_path)
      File.write("#{out_dir}/#{yc_id}.htm", vhtml)
    rescue ex
      File.open("tmp/error-crits-body.log", "a", &.puts(inp_path))
    end
  end
end

def convert(cv_mt, inp_path : String)
  String.build do |io|
    File.each_line(inp_path) do |line|
      next if line.blank?

      io << "<p>"
      cv_mt.cv_plain(line).to_txt(io)
      io << "</p>"
    end
  end
end
