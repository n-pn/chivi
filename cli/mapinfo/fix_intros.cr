require "../../src/appcv/nv_info"
require "./_bookgen"

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

        unless yintro.empty?
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
        fintro ||= bintro unless bintro.empty?
      end

      bintro ||= yintro || fintro

      NvBintro.set!(bhash, bintro, force: true) if bintro
      puts "- [fix_intros] <#{idx}/#{bhashes.size}>".colorize.blue if idx % 100 == 0
    end

    NvBintro.save!(clean: false)
  end

  SEEDS = {} of String => Bookgen::Seed

  def get_intro(sname : String, snvid : String)
    SEEDS[sname] ||= Bookgen::Seed.new(sname)
    SEEDS[sname].get_intro(snvid)
  end
end

worker = CV::FixIntros.new
worker.fix!
