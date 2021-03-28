require "../../src/appcv/nvinfo"

class CV::FixGenres
  ORDERS = {"hetushu", "shubaow", "paoshu8",
            "zhwenpg", "5200", "nofff",
            "zxcs_me", "duokan8", "rengshu",
            "xbiquge", "bqg_5200"}

  def fix!
    bhashes = Dir.children(Nvinfo::DIR).map { |x| File.basename(x, ".tsv") }
    bhashes.each_with_index(1) do |bhash, idx|
      nvinfo = Nvinfo.new(bhash)

      genres = [] of String
      yousuu = [] of String

      chseed = nvinfo._meta.get("chseed") || ["chivi"]
      chseed.sort_by! { |sname| ORDERS.index(sname) || 99 }

      chseed.each do |sname|
        snvid = nvinfo.get_chseed(sname)[0]
        get_genres(sname, snvid).each do |genre|
          genres.concat(NvUtils.fix_genre_zh(genre))
        end
      end

      if y_nvid = nvinfo._meta.fval("yousuu")
        get_genres("yousuu", y_nvid).each do |genre|
          yousuu.concat(NvUtils.fix_genre_zh(genre))
          genres.concat(NvUtils.fix_genre_zh(genre))
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

      vi_genres = zh_genres.map { |g| NvUtils.fix_genre_vi(g) }
      vi_genres = ["Loại khác"] if vi_genres.empty?

      nvinfo.set_genres(vi_genres, force: true)
      nvinfo.save!(clean: false)

      if idx % 100 == 0
        puts "- [fix_genres] <#{idx}/#{bhashes.size}>".colorize.blue
        NvIndex.save!(clean: false)
      end
    end

    NvIndex.save!(clean: true)
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
