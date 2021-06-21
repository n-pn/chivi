require "../../src/appcv/nv_info"

class CV::FixGenres
  ORDERS = {"hetushu", "shubaow", "paoshu8",
            "zhwenpg", "5200", "nofff",
            "zxcs_me", "duokan8", "rengshu",
            "xbiquge", "bqg_5200"}

  def fix!
    bhashes = NvFields.bhashes
    bhashes.each_with_index(1) do |bhash, idx|
      yousuu = [] of String
      genres = [] of String

      if ynvid = NvFields.yousuu.fval(bhash)
        get_genres("yousuu", ynvid).each do |genre|
          yousuu.concat(NvGenres.fix_zh_name(genre))
          genres.concat(NvGenres.fix_zh_name(genre))
        end
      end

      snames = NvChseed.get_list(bhash)
      snames.sort_by! { |s| ORDERS.index(s) || 99 }

      snames.each do |sname|
        snvid = NvChseed.get_nvid(sname, bhash) || bhash
        input = get_genres(sname, snvid)
        genres.concat(NvGenres.fix_zh_names(input))
      end

      genres = genres.reject("其他").tally.to_a
      top_genres = genres.select(&.[1].> 1)

      if top_genres.size > 0
        zh_genres = top_genres.sort_by(&.[1].-).first(3).map(&.[0])
      elsif yousuu.size > 0
        zh_genres = yousuu.first(2)
      elsif genres.size > 0
        zh_genres = genres.first(3).map(&.[0])
      else
        zh_genres = [] of String
      end

      vi_genres = zh_genres.map { |g| NvGenres.fix_vi_name(g) }
      vi_genres = ["Loại khác"] if vi_genres.empty?

      NvGenres.set!(bhash, vi_genres, force: true)
      puts "- [fix_genres] <#{idx}/#{bhashes.size}>".colorize.blue if idx % 100 == 0
    end

    NvGenres.save!(clean: false)
  end

  getter cache = {} of String => ValueMap

  def get_genres(sname : String, snvid : String)
    file = "_db/_seeds/#{sname}/genres.tsv"
    map = cache[sname] ||= ValueMap.new(file, mode: 1)
    map.get(snvid) || [] of String
  end
end

worker = CV::FixGenres.new
worker.fix!
