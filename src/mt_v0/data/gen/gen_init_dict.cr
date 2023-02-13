require "json"
require "../vp_init"

INP = "var/dicts/inits/regular-terms-cv.tsv"
MT::VpInit.repo.open_tx do |db|
  db.exec "delete from terms"

  sql = <<-SQL
  insert into terms(id, zstr, tags, mtls, raw_tags, raw_mtls)
  values(?, ?, ?, ?, ?, ?)
  SQL

  id = 0

  File.each_line(INP) do |line|
    rows = line.split('\t')
    next if rows.size < 2

    id += 1

    zstr = rows[0]
    tags = rows[1].split.flat_map(&.split(':').[0]).join(' ')

    cv_mtls = rows[2]? || ""
    bi_mtls = rows[3]? || ""
    qt_mtls = rows[4]? || ""

    mtls = cv_mtls
    mtls = qt_mtls if mtls.blank?
    mtls = bi_mtls if mtls.blank?
    mtls = mtls.split('ǀ').first

    raw_tags = {ts: rows[1]}.to_json
    raw_mtls = {cv: cv_mtls || "", bi: bi_mtls || "", qt: qt_mtls || ""}.to_json

    db.exec sql, id, zstr, tags, mtls, raw_tags, raw_mtls
  end
end
