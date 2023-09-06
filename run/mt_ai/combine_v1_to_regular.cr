require "../../src/mt_ai/data/db_term"

def import_from_old_regular
  existed = MT::DbTerm.db("regular").open_ro do |db|
    query = "select zstr, cpos from terms"
    db.query_all(query, as: {String, String}).to_set
  end

  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-1").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)
      entries << entry unless existed.includes?({entry.zstr, entry.cpos})
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_noun_dic
  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-20").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)

      if entry.cpos == "_"
        entry.cpos = "NN"
        entry.prop = "Npos"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_verb_dic
  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-21").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)

      if entry.cpos == "_"
        entry.cpos = "VV"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_adjt_dic
  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-22").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)

      if entry.cpos == "_"
        entry.cpos = "VA"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_advb_dic
  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-23").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)

      entry.cpos = "AD"
      entry.fix_enums!

      entries << entry
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_uzhi_dic
  entries = [] of MT::DbTerm

  MT::DbTerm.db("_old/-24").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::DbTerm)

      entry.cpos = "NP"
      entry.fix_enums!

      entries << entry
    end
  end

  puts entries.size

  MT::DbTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

# import_from_old_uzhi_dic
