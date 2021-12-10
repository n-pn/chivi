class CV::MtDict
  SEP = "ǀ"
  DIR = "var/vpdicts/_mtl"

  CAST_NOUNS = new("#{DIR}/cast-nouns.tsv")
  CAST_VERBS = new("#{DIR}/cast-verbs.tsv")
  CAST_ADJTS = new("#{DIR}/cast-adjts.tsv")

  QUANTI_NOUNS = new("#{DIR}/quanti-nouns.tsv")
  QUANTI_TIMES = new("#{DIR}/quanti-times.tsv")
  QUANTI_VERBS = new("#{DIR}/quanti-verbs.tsv")

  getter data = {} of String => String
  getter _log = {} of String => Array(String)

  forward_missing_to @data

  def initialize(@file : String)
    @ftab = @file.sub(".tsv", ".tab")
    load!(@file)
    load!(@ftab) if File.exists?(@ftab)
  end

  def load!(file : String)
    File.read_lines(file).each { |line| put(line.split('\t')) }
  end

  def put!(entry : Array(String)) : Nil
    put(entry)
    File.open(@ftab, "a") { |io| io << "\n" << entry.join('\t') }
  end

  def put(entry : Array(String)) : Nil
    key = rows[0]
    _log[key] = rows

    if (val = rows[1]?) && !val.blank?
      data[key] = val.split(SEP, 2)[0]
    else
      data.delete(key)
    end
  end
end
