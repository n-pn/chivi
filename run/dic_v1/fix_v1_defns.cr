require "sqlite3"

db = DB.open("sqlite3:var/mtapp/v1dic/v1_defns.dic")
at_exit { db.close }

struct Term
  include DB::Serializable
  getter id : Int32, key : String
  getter dic : Int32, tab : Int32
  property mtime : Int64, uname : String

  def typo_of?(newer : Term)
    (newer.mtime - @mtime) < 10 && newer.uname == @uname
  end
end

terms = db.query_all("select id, key, dic, tab, mtime, uname from defns order by mtime desc, id desc", as: Term)

puts terms.size

bases = {} of Tuple(Int32, String) => Term
temps = {} of Tuple(Int32, String) => Term
users = {} of Tuple(Int32, String, String) => Term

expired = [] of Term
removed = [] of Term

terms.each do |term|
  ukey = {term.dic, term.key}

  case term.tab
  when 1
    if newer = bases[ukey]?
      target = term.typo_of?(newer) ? removed : expired
      newer.mtime = term.mtime
      target << term
    else
      bases[ukey] = term
    end
  when 2
    if bases[ukey]? || temps[{ukey}]?
      removed << term
    else
      temps[ukey] = term
    end
  when 3
    ukey_2 = {term.dic, term.key, term.uname}
    if users[ukey_2]?
      removed << term
    else
      users[ukey_2] = term
    end
  end
end

puts "to be removed: #{removed.size}"
puts "to be expired: #{expired.size}"

db.exec "begin"

removed.each do |term|
  db.exec "delete from defns where id = ?", term.id
end

expired.each do |term|
  db.exec "update defns set tab = -tab where id = ?", term.id
end

db.exec "commit"
