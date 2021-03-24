require "../../src/filedb/nvinfo"

class CV::FixIntros
  ORDERS = {"hetushu", "shubaow", "paoshu8",
            "zhwenpg", "5200", "nofff",
            "zxcs_me", "duokan8", "rengshu",
            "xbiquge", "bqg_5200"}

  def fix!
    bhashes = Dir.children(Nvinfo::DIR).map { |x| File.basename(x, ".tsv") }
    bhashes.each_with_index(1) do |bhash, idx|
      nvinfo = Nvinfo.new(bhash)

      yintro, bintro = nil, nil

      if y_nvid = nvinfo._meta.fval("yousuu")
        yintro = get_intro("yousuu", y_nvid)

        if yintro.size > 1
          nvinfo.set_bintro(yintro, force: true)
          next
        end
      end

      chseed = nvinfo._meta.get("chseed") || ["chivi"]
      chseed.sort_by! { |sname| ORDERS.index(sname) || 99 }

      chseed.each do |sname|
        snvid = nvinfo.get_chseed(sname)[0]
        bintro = get_intro(sname, snvid)
        break if bintro.size > 1
      end

      nvinfo.set_bintro(bintro, force: true) if bintro

      if idx % 100 == 0
        puts "- [fix_intros] <#{idx}/#{bhashes.size}>".colorize.blue
      end
    end
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
