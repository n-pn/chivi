# require "crorm"

# class ZH::ZhChap
#   include Crorm::Model
#   self.table = "chaps"

#   column ch_no : Int32, primary: true # chaper index number
#   column s_cid : Int32                # chapter file name

#   column chdiv : String = "" # volume name
#   column chnum : String = "" # chapter numering, eg: 第650章

#   column title : String = "" # rest of chapter title

#   column c_len : Int32 = 0 # char count
#   column p_len : Int32 = 0 # part count

#   column mtime : Int64 = 0   # last modification time
#   column uname : String = "" # last user saved/edited the chapter

#   def save!(repo : Crorm::Adapter)
#     fields, values = self.get_changes
#     repo.insert(self.class.table, fields, values, false)
#   end

#   def self.save!(sname : String, s_bid : Int32, entry : self)
#     open_db(sname, s_bid) do |db|
#       fields, values = entry.get_changes
#       holder = Array.new(fields.size, "?").join(", ")

#       db.exec <<-SQL, args: values
#         replace into chaps (#{fields.join(", ")}) values (#{holder})
#       SQL
#     end
#   end

#   def self.open_db(sname : String, s_bid : Int32)
#     db_path = "var/chaps/seeds/#{sname}/#{s_bid}.db"
#     DB.open("sqlite3://./#{db_path}") { |db| yield db }
#   end

#   def self.init_db(sname : String, s_bid : Int32)
#     open_db(sname, s_bid) do |db|
#       db.exec "drop table if exists chaps"

#       db.exec <<-SQL
#         create table chaps (
#           ch_no integer primary key,
#           s_cid integer not null,

#           chdiv varchar not null default "",
#           chnum varchar not null default "",
#           title varchar not null default "",

#           c_len integer not null default 0,
#           p_len integer not null default 0,

#           mtime integer not null default 0,
#           uname varchar not null default ''
#         );
#       SQL
#     end
#   end
# end
