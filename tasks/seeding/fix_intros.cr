require "../../src/filedb/nvinfo"

class CV::Seeds::FixIntros
  getter source : ValueMap = NvValues.source

  def fix!
    @source.data.each_with_index(1) do |(b_hash, values), idx|
      yintro, bintro = nil, nil

      if y_nvid = NvValues.yousuu.fval(b_hash)
        yintro = get_intro("yousuu", y_nvid)

        if yintro.size > 1
          NvValues.set_bintro(b_hash, yintro, force: true)
          next
        end
      end

      seeds = values.each_with_object({} of String => String) do |x, h|
        s_name, s_nvid = x.split("/")
        h[s_name] = s_nvid
      end

      {"hetushu", "shubaow", "zhwenpg", "5200", "duokan8", "nofff",
       "zxcs_me", "paoshu8", "rengshu", "xbiquge", "bqg_5200"}.each do |seed|
        next unless s_nvid = seeds[seed]?
        bintro = get_intro(seed, s_nvid)
        break unless bintro.empty?
      end

      unless bintro && !bintro.empty?
        if yintro
          bintro = yintro
        elsif s_nvid = seeds["jx_la"]?
          bintro = get_intro("jx_la", s_nvid)
        else
          next
        end
      end

      NvValues.set_bintro(b_hash, bintro, force: true)

      if idx % 100 == 0
        puts "- [fix_intros] <#{idx}/#{@source.size}>".colorize.blue
      end
    end
  end

  def get_intro(seed : String, s_nvid : String)
    intro_file = "_db/_seeds/#{seed}/intros/#{s_nvid}.txt"
    File.read_lines(intro_file).map(&.strip).reject(&.empty?)
  rescue err
    [] of String
  end
end

worker = CV::Seeds::FixIntros.new
worker.fix!
