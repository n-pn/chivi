require "../../_data/remote/rmseed"
require "../../_data/remote/rmstem"
require "../../_data/remote/zhstem"

class SeedRmstem
  getter host, seed

  def initialize(sname : String, tspan = 100.days)
    @host = Rmhost.from_name!(sname)
    @seed = Rmseed.new(@host)
    @stale = Time.utc - tspan
  end

  def seed_book(bid : String | Int32, force : Bool = false)
    stem_file = @host.stem_file(bid)
    stem_path = @host.stem_href(bid)

    html = @seed.read_page(stem_path, stem_file, stale: @stale)
    parser = Rmstem.new(html, @host, bid)

    zhstem = Zhstem.load(@host.seedname, bid)

    zhstem.open_tx do |db|
      chlist = parser.chap_list

      chlist.each do |chinfo|
        zhstem.upsert_info(
          db: db,
          ch_no: chinfo.ch_no, s_cid: chinfo.s_cid,
          ctitle: chinfo.ctitle, subdiv: chinfo.subdiv,
        )
      end

      puts "- <#{@host.seedname}/#{bid}> #{chlist.size} chapters added/updated!"
    end
  end
end

task = SeedRmstem.new("!hetushu")

mbid = task.seed.get_mbid

mbid.to_i.downto(7000) do |bid|
  task.seed_book(bid)
end
