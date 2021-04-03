require "../../src/appcv/nv_info"

class CV::FixIntros
  ORDERS = {"hetushu", "shubaow", "paoshu8",
            "zhwenpg", "5200", "nofff",
            "zxcs_me", "duokan8", "rengshu",
            "xbiquge", "bqg_5200"}

  def fix!
    bhashes = NvFields.bhashes
    bhashes.each_with_index(1) do |bhash, idx|
      yintro = bintro = fintro = nil

      if ynvid = NvFields.yousuu.fval(bhash)
        yintro = get_intro("yousuu", ynvid)

        if yintro.size > 1
          NvBintro.set!(bhash, yintro, force: true)
          next
        end
      end

      snames = NvChseed.get_list(bhash)
      snames.sort_by! { |s| ORDERS.index(s) || 99 }

      snames.each do |sname|
        next unless seed = NvChseed.get_seed(sname, bhash)
        bintro = get_intro(sname, seed[0])
        break if bintro.size > 1
        fintro ||= bintro
      end

      bintro ||= yintro || fintro

      NvBintro.set!(bhash, bintro, force: true) if bintro

      if idx % 100 == 0
        puts "- [fix_intros] <#{idx}/#{bhashes.size}>".colorize.blue
        NvBintro.save!(clean: false)
      end
    end

    NvBintro.save!(clean: false)
  end

  def get_intro(sname : String, snvid : String)
    intro_file = "_db/_seeds/#{sname}/intros/#{snvid}.txt"
    File.read_lines(intro_file).map(&.strip).reject(&.empty?)
  rescue err
    [] of String
  end
end

worker = CV::FixIntros.new
worker.fix!
