require "option_parser"
require "../shared/bootstrap"

class CV::FetchText
  DIR = "var/chtexts/chivi"

  @snvid : String

  def initialize(nvinfo : Nvinfo)
    @snvid = nvinfo.bhash
    zhbook = Zhbook.load!(nvinfo, 0)
    zhbook.copy_newers!(nvinfo.zhbooks.to_a)

    crawl_all = false # should_crawl_all?(nvinfo)
    @queue = [] of ChInfo

    files = Dir.glob("#{DIR}/#{@snvid}/*.tsv")
    files.each do |file|
      group = File.basename(file, ".tsv")
      next if group == "-"

      infos = ChList.new(file)
      infos.data.each_value do |chinfo|
        @queue << chinfo if should_crawl?(chinfo, crawl_all)
      end
    end
  end

  def should_crawl_all?(nvinfo : Nvinfo)
    return true if nvinfo.cv_voters >= 8 || nvinfo.ys_voters >= 64
    Ubmemo.query.where(nvinfo_id: nvinfo.id).where("status > 0").count > 0
  end

  # load all or load first 64 chapters and every 4th chapters
  private def should_crawl?(chinfo : ChInfo, crawl_all = false)
    return false if chinfo.chars > 0 || !SeedUtil.remote?(chinfo.o_sname, privi: 5)
    crawl_all || chinfo.chidx <= 64 || chinfo.chidx % 8 == 0
  end

  def crawl!(label = "1/1")
    return if @queue.empty?

    puts "- <#{label}> [zhtext/#{@snvid}] #{@queue.size} entries".colorize.light_cyan

    @queue.each_with_index(1) do |chinfo, idx|
      chtext = Chtext.new("chivi", @snvid, chinfo)
      chtext.fetch!(mkdir: false, lbl: "#{label}: #{idx}/#{@queue.size}")
      update_chinfo!(chinfo)
    ensure
      sleep_by_sname(chinfo.o_sname)
    end
  end

  def update_chinfo!(chinfo : ChInfo)
    ChList.load!("chivi", @snvid, chinfo.pgidx).update!(chinfo)

    # reset info to save to origin seed
    sname, chinfo.o_sname = chinfo.o_sname, "" # clear o_sname
    chinfo.chidx = chinfo.o_chidx              # recover original chap _index
    ChList.load!(sname, chinfo.o_snvid, chinfo.pgidx).update!(chinfo)
  end

  def sleep_by_sname(sname : String)
    case sname
    when "shubaow", "biqu5200"
      sleep Random.rand(1000..2000).milliseconds
    end
  end

  def self.run!(argv = ARGV)
    workers = 8

    OptionParser.parse(ARGV) do |opt|
      opt.banner = "Usage: fetch_zhtexts [arguments]"
      opt.on("-t WORKERS", "Parallel workers") { |x| workers = x.to_i }
    end

    total = Nvinfo.query.count
    channel = Channel(Nil).new(workers)

    nvinfos = Nvinfo.query.order_by(weight: :desc).to_a

    nvinfos.each_with_index(1) do |nvinfo, idx|
      channel.receive if idx > workers
      spawn do
        new(nvinfo).crawl!("#{idx}/#{total}")
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
  end
end

CV::FetchText.run!
