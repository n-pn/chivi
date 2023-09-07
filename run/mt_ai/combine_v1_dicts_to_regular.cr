require "../../src/mt_ai/data/vi_term"

def import_from_old_regular
  existed = MT::ViTerm.db("regular").open_ro do |db|
    query = "select zstr, cpos from terms"
    db.query_all(query, as: {String, String}).to_set
  end

  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-1").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)
      entries << entry unless existed.includes?({entry.zstr, entry.cpos})
    end
  end

  MT::ViTerm.db("_old/-2").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)
      entries << entry unless existed.includes?({entry.zstr, entry.cpos})
    end
  end

  MT::ViTerm.db("_old/-3").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)
      entries << entry unless existed.includes?({entry.zstr, entry.cpos})
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_noun_dic
  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-20").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)

      if entry.cpos == "_"
        entry.cpos = "NN"
        entry.attr = "Npos"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_verb_dic
  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-21").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)

      if entry.cpos == "_"
        entry.cpos = "VV"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_adjt_dic
  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-22").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)

      if entry.cpos == "_"
        entry.cpos = "VA"
        entry.fix_enums!
      end

      entries << entry
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_advb_dic
  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-23").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)

      entry.cpos = "AD"
      entry.fix_enums!

      entries << entry
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

def import_from_old_uzhi_dic
  entries = [] of MT::ViTerm

  MT::ViTerm.db("_old/-24").open_ro do |db|
    db.query_each("select * from terms") do |rs|
      entry = rs.read(MT::ViTerm)

      entry.cpos = "NP"
      entry.fix_enums!

      entries << entry
    end
  end

  puts entries.size

  MT::ViTerm.db("regular").open_tx do |db|
    entries.each(&.upsert!(db: db))
  end
end

import_from_old_regular
import_from_old_noun_dic
import_from_old_verb_dic
import_from_old_adjt_dic
import_from_old_advb_dic
import_from_old_uzhi_dic
