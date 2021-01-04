require "../../src/filedb/nvinfo"

class CV::Seeds::FixGenres
  getter input : ValueMap = Nvinfo.chseed

  def fix!
    @input.data.each_with_index do |(bhash, seeds), idx|
      genres = [] of String
      yousuu = [] of String

      seeds.each do |entry|
        seed, sbid = entry.split("/")
        get_genres(seed, sbid).each do |genre|
          genres.concat(Nvinfo::Utils.fix_zh_genre(genre))
        end
      end

      if ybid = Nvinfo.yousuu.fval(bhash)
        get_genres("yousuu", ybid).each do |genre|
          yousuu.concat(Nvinfo::Utils.fix_zh_genre(genre))
          genres.concat(Nvinfo::Utils.fix_zh_genre(genre))
        end
      end

      genres = genres.reject("其他").tally.to_a
      top_genres = genres.select(&.[1].> 1)

      if top_genres.size > 0
        zh_genres = top_genres.sort_by(&.[1].-).first(3).map(&.[0])
      elsif yousuu.size > 0
        zh_genres = yousuu.first(3)
      elsif genres.size > 0
        zh_genres = genres.first(3).map(&.[0])
      else
        zh_genres = [] of String
      end

      vi_genres = zh_genres.map { |g| Nvinfo::Utils.fix_vi_genre(g) }
      vi_genres = ["Loại khác"] if vi_genres.empty?
      Nvinfo.set_bgenre(bhash, vi_genres, force: true)

      if idx % 100 == 99
        puts "- [fix_genres] <#{idx + 1}/#{@input.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    save!(mode: :full)
  end

  def get_genres(seed : String, sbid : String)
    genre_map(seed).get(sbid) || [] of String
  end

  getter cache = {} of String => ValueMap

  def genre_map(seed : String)
    cache[seed] ||= ValueMap.new("_db/_seeds/#{seed}/bgenre.tsv", mode: 2)
  end

  def save!(mode : Symbol = :full)
    Nvinfo.bgenre.save!(mode: mode)
    Nvinfo::Tokens.bgenre.save!(mode: mode)
  end
end

worker = CV::Seeds::FixGenres.new
worker.fix!
