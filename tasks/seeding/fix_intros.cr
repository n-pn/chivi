require "../../src/filedb/nvinfo"

class CV::Seeds::FixIntros
  getter source : ValueMap = NvValues.source

  def fix!
    @source.data.each_with_index(1) do |(bhash, values), idx|
      yintro, bintro = nil, nil

      if y_nvid = NvValues.yousuu.fval(bhash)
        yintro = get_intro("yousuu", y_nvid)

        if yintro.size > 1
          NvValues.set_bintro(bhash, yintro, force: true)
          next
        end
      end

      seeds = values.each_with_object({} of String => String) do |x, h|
        s_name, snvid = x.split("/")
        h[s_name] = snvid
      end

      {"hetushu", "shubaow", "paoshu8", "zhwenpg", "5200", "nofff",
       "zxcs_me", "duokan8", "rengshu", "xbiquge", "bqg_5200"}.each do |seed|
        next unless snvid = seeds[seed]?
        bintro = get_intro(seed, snvid)
        break if bintro.size > 1
      end

      unless bintro && !bintro.empty?
        if yintro
          bintro = yintro
        elsif snvid = seeds["jx_la"]?
          bintro = get_intro("jx_la", snvid)
        else
          next
        end
      end

      NvValues.set_bintro(bhash, bintro, force: true)

      if idx % 100 == 0
        puts "- [fix_intros] <#{idx}/#{@source.size}>".colorize.blue
      end
    end
  end

  def get_intro(seed : String, snvid : String)
    intro_file = "_db/_seeds/#{seed}/intros/#{snvid}.txt"
    File.read_lines(intro_file).map(&.strip).reject(&.empty?)
  rescue err
    [] of String
  end
end

worker = CV::Seeds::FixIntros.new
worker.fix!
