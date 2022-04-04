require "tabkv"

module CV::Seed
  record Bindex, stime : Int64, btitle : String, author : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1], rows[2])
    end

    def to_tsv
      "#{@stime}\#{@btitle}\t#{@author}"
    end

    def fix_names
      BookUtil.fix_names(@btitle, @author)
    end
  end

  record Status, status : Int32, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1]?)
    end

    def to_tsv
      "#{@status}\t#{@rawstr}"
    end
  end

  record Mftime, update : Int64, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1]?)
    end

    def to_tsv
      "#{@update}\t#{@rawstr}"
    end
  end

  record Rating, voters : Int32, rating : Int32 do
    def self.rand
      {Random.rand(25..50), Random.rand(40..50)}
    end

    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i)
    end

    def to_tsv
      "#{@voters}\t#{@rating}"
    end
  end

  record Chsize, chap_count : Int32, last_schid : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i)
    end

    def to_tsv
      "#{@chap_count}\t#{@last_schid}"
    end
  end

  record Origin, pub_link : String, pub_name : String? do
    def self.from_tsv(rows : Array(String))
      pub_link = rows[0]
      pub_name = rows[1]? || extract_name(pub_link)
      new(pub_link, pub_name)
    end

    def to_tsv
      "#{@pub_link}\t#{@pub_name}"
    end
  end

  record Ystats, word_count : Int32, crit_count : Int32, list_count : Int32 do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i, rows[2].to_i)
    end

    def to_tsv
      {@word_count, @crit_count, @list_count}.join('\t')
    end
  end
end
