require "pg"
require "colorize"
require "../../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

yc_ids = PG_DB.query_all "select yc_id from yscrits where ztext = ''", as: String

TXT_DIR = "var/ysapp/crits-txt"

# PG_DB.exec "begin transaction"
yc_ids.each_with_index(1) do |yc_id, idx|
  puts "<#{idx}> #{yc_id}" if idx % 1000 == 0

  group = yc_id[0..3]

  ztext_path = "#{TXT_DIR}/#{group}-zh/#{yc_id}.txt"
  vhtml_path = "#{TXT_DIR}/#{group}-vi/#{yc_id}.htm"

  ztext = File.read(ztext_path) rescue ""
  vhtml = File.read(vhtml_path) rescue ""

  next if ztext.empty? && vhtml.empty?

  ztext = ztext.tr("\u0000", "\n").lines.map(&.strip).reject(&.empty?).join('\n')
  vhtml = vhtml.tr("\u0000", "\n")

  PG_DB.exec "update yscrits set ztext = $1, vhtml = $2 where yc_id = $3", ztext, vhtml, yc_id
end

# PG_DB.exec "commit"
