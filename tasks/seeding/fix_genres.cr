require "../../src/filedb/nvinfo"

class CV::Seeds::FixGenres
  getter input : ValueMap = NvFields.chseed

  def fix!
    @input.data.each_with_index do |(bhash, seeds), idx|
      genres = [] of String
      yousuu = [] of String

      seeds.each do |entry|
        seed, sbid = entry.split("/")
        get_genres(seed, sbid).each do |genre|
          genres.concat(NvShared.fix_zh_genre(genre))
        end
      end

      if ybid = NvFields.yousuu.fval(bhash)
        get_genres("yousuu", ybid).each do |genre|
          yousuu.concat(NvShared.fix_zh_genre(genre))
          genres.concat(NvShared.fix_zh_genre(genre))
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

      vi_genres = zh_genres.map { |g| NvShared.fix_vi_genre(g) }
      vi_genres = ["Loại khác"] if vi_genres.empty?
      NvFields.set_bgenre(bhash, vi_genres, force: true)

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
    NvFields.bgenre.save!(mode: mode)
    NvTokens.bgenre.save!(mode: mode)
  end
end

worker = CV::Seeds::FixGenres.new
worker.fix!
