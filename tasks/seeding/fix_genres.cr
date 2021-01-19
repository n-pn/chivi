require "../../src/filedb/nvinfo"

class CV::S_names::FixGenres
  getter source : ValueMap = NvValues.source

  def fix!
    @source.data.each_with_index(1) do |(b_hash, values), idx|
      genres = [] of String
      yousuu = [] of String

      values.each do |entry|
        s_name, s_nvid = entry.split("/")
        get_genres(s_name, s_nvid).each do |genre|
          genres.concat(NvHelper.fix_zh_genre(genre))
        end
      end

      if y_nvid = NvValues.yousuu.fval(b_hash)
        get_genres("yousuu", y_nvid).each do |genre|
          yousuu.concat(NvHelper.fix_zh_genre(genre))
          genres.concat(NvHelper.fix_zh_genre(genre))
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

      vi_genres = zh_genres.map { |g| NvHelper.fix_vi_genre(g) }
      vi_genres = ["Loại khác"] if vi_genres.empty?
      Nvinfo.set_genres(b_hash, vi_genres, force: true)

      if idx % 100 == 0
        puts "- [fix_genres] <#{idx}/#{@source.size}>".colorize.blue
        save!(mode: :upds)
      end
    end

    save!(mode: :full)
  end

  def get_genres(s_name : String, s_nvid : String)
    genre_map(s_name).get(s_nvid) || [] of String
  end

  getter cache = {} of String => ValueMap

  def genre_map(s_name : String)
    cache[s_name] ||= ValueMap.new("_db/_seeds/#{s_name}/genres.tsv", mode: 2)
  end

  def save!(mode : Symbol = :full)
    NvValues.genres.save!(mode: mode)
    NvTokens.genres.save!(mode: mode)
  end
end

worker = CV::S_names::FixGenres.new
worker.fix!
