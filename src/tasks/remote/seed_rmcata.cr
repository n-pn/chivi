require "../../_data/remote/rmseed"
require "../../_data/remote/rmcata"
require "../../_data/remote/zhcata"

class SeedRmcata
  getter conf, seed

  def initialize(sname : String, tspan = 100.days)
    @conf = Rmconf.load_known!(sname)
    @seed = Rmseed.new(@conf)
    @stale = Time.utc - tspan
  end

  def seed_book(bid : String | Int32, force : Bool = false)
    cata_file = @conf.cata_file_path(bid)
    cata_path = @conf.make_cata_path(bid)

    html = @seed.read_page(cata_path, cata_file, stale: @stale)
    parser = Rmcata.new(html, @conf, bid)

    zhcata = Zhcata.load(@conf.seedname, bid)

    zhcata.open_tx do |db|
      chlist = parser.chap_list

      chlist.each do |chinfo|
        zhcata.upsert_info(
          db: db,
          ch_no: chinfo.ch_no, s_cid: chinfo.s_cid,
          ctitle: chinfo.ctitle, subdiv: chinfo.subdiv,
        )
      end

      puts "- <#{@conf.seedname}/#{bid}> #{chlist.size} chapters added/updated!"
    end
  end
end

task = SeedRmcata.new("!hetushu")

mbid = task.seed.get_mbid

mbid.to_i.downto(7000) do |bid|
  task.seed_book(bid)
end