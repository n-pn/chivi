require "pg"
require "crorm"

ZR_DB = DB.open("postgres://postgres:postgres@localhost:5436/zroot")
at_exit { ZR_DB.close }
