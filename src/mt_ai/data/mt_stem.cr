module MT::MtStem
  extend self

  DIR = "var/mtdic/mt_ai/core"

  def self.load_tsv(dname : String)
    db_path = "#{DIR}/#{dname}.tsv"

    hash = {} of String => String
    return hash unless File.file?(db_path)

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      next if cols.size < 2
      hash[cols[0]] = cols[1]
    end

    hash
  end

  class_getter map_noun_stem : Hash(String, String) { load_tsv("noun_stem") }
  class_getter map_verb_stem : Hash(String, String) { load_tsv("verb_stem") }

  def self.noun_stem(zstr : String)
    self.map_noun_stem[zstr] ||= zstr.size < 2 ? zstr : init_noun_stem(zstr)
  end

  def self.init_noun_stem(zstr : String)
    # TODO: check for common suffixes
    lchar = zstr[-1]
    lchar == '子' ? zstr[-2].to_s : lchar.to_s
  end

  def self.verb_stem(zstr : String)
    self.map_verb_stem[zstr] ||= zstr.size < 2 ? zstr : init_verb_stem(zstr)
  end

  def self.init_verb_stem(zstr : String)
    # TODO: check for common prefixes
    zstr[0].to_s
  end
end
