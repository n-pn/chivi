require "../../src/filedb/nvinfo"

class CV::Seeds::FixIntros
  getter chseed : ValueMap = NvFields.chseed

  def fix!
    @chseed.data.each_with_index do |(bhash, seeds), idx|
      yintro, bintro = nil, nil

      if ybid = NvFields.yousuu.fval(bhash)
        yintro = get_intro("yosuu", ybid)

        if yintro.size > 1
          NvFields.set_bintro(bhash, yintro, force: true)
          next
        end
      end

      seeds = seeds.each_with_object({} of String => String) do |x, h|
        seed, sbid = x.split("/")
        h[seed] = sbid
      end

      {"hetushu", "shubaow", "zhwenpg", "5200", "duokan8", "nofff",
       "zxcs_me", "paoshu8", "rengshu", "xbiquge", "biquge5200"}.each do |seed|
        next unless sbid = seeds[seed]?
        bintro = get_intro(seed, sbid)
        break unless bintro.empty?
      end

      unless bintro && !bintro.empty?
        if yintro
          bintro = yintro
        elsif sbid = seeds["jx_la"]?
          bintro = get_intro("jx_la", sbid)
        else
          next
        end
      end

      NvFields.set_bintro(bhash, bintro, force: true)

      if idx % 100 == 99
        puts "- [fix_intros] <#{idx + 1}/#{@chseed.size}>".colorize.blue
      end
    end
  end

  def get_intro(seed : String, sbid : String)
    intro_file = "_db/_seeds/#{seed}/intros/#{sbid}.txt"
    File.read_lines(intro_file)
  rescue err
    [] of String
  end
end

worker = CV::Seeds::FixIntros.new
worker.fix!
