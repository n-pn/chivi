require "../v1_defn"
require "../v1_dict"

db = Crorm::Sqlite3::DB.new M1::DbDefn.db_path
db.start_tx

# mtime, dname, key, vals, tags, prio, uname, tab, line, idx
alias Entry = Tuple(Int64, String, String, Array(String), Array(String), Int32, String, Int32, String?, Int32?)

LAST = ARGV[0]?.try(&.to_i) || 3
files = Dir.glob("var/dicts/ulogs/*.jsonl").sort!

files.last(LAST).each do |file|
  File.each_line(file) do |line|
    entry = Entry.from_json(line)
    add_entry(db, entry)
  rescue err
    puts line
    puts err.inspect_with_backtrace
  end
end

db.commit_tx
db.close

def find_existing_id(db, defn)
  query = "select id from defns where dic = ? and key = ? and mtime = ? and uname = ? limit 1"
  db.query_one? query, defn.dic, defn.key, defn.mtime, defn.uname, as: Int32
end

def mark_prev_as_outdated(db, defn : M1::DbDefn)
  args = [defn.dic, defn.key, defn.tab, defn.mtime] of DB::Any
  query = "select id, mtime, uname from defns where dic = ? and key = ? and tab = ? and mtime < ?"

  if defn.tab == 3 # user dict
    query += " and uname = ?"
    args << defn.uname
  end

  query += " order by mtime desc"

  most_recent = nil

  to_delete = [] of {Int32, Int32}

  db.query_each query, args: args do |rs|
    id, mtime, uname = rs.read(Int32, Int64, String)

    if uname != defn.uname
      _flag = -1
      most_recent ||= id
    elsif defn.mtime - mtime > 10
      most_recent ||= id
      _flag = -2
    else
      _flag = -3
    end

    to_delete << {_flag, id}
  end

  to_delete.each do |_flag, id|
    db.exec "update defns set _flag = ? where id = ?", _flag, id
  end

  most_recent || 0
end

# mtime, dname, key, vals, tags, prio, uname, tab, line, idx
def add_entry(db, entry)
  defn = M1::DbDefn.new

  defn.dic = entry[1]
  defn.tab = entry[7] &+ 1

  defn.key = entry[2]
  defn.val = entry[3]

  defn.ptag = entry[4]
  defn.prio = entry[5]

  defn.uname = entry[6]
  defn.mtime = Time.unix(entry[0])

  defn._ctx = "#{entry[8]}:#{entry[9]}"

  defn._flag = 1

  defn.id = find_existing_id(db, defn)

  defn._prev = mark_prev_as_outdated(db, defn)

  fields, values = defn.get_changes
  db.insert("defns", fields, values, Crorm::Sqlite3::SQL::InsertMode::Replace)

  puts defn.to_json
end
