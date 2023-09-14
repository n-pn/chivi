require "../../../zroot/html_parser/raw_rmchap"

module WN::TextFetch
  extend self

  def fetch(seed : Wnstem, chap : Chinfo, uname : String = "", force : Bool = false)
    seed.mkdirs!
    stale = Time.utc - (force ? 1.minutes : 20.years)

    _path = chap._path

    case
    when _path.starts_with?("http")
      parser = RawRmchap.from_link(_path, stale: stale)
    when _path.starts_with?('!')
      sname, s_bid, s_cid = _path.split('/')
      parser = RawRmchap.from_seed(sname, s_bid, s_cid, stale: stale)
    when seed.remote?
      host = Rmhost.from_name!(seed.sname)
      cpath = _path.starts_with?('/') ? _path : host.make_chap_path(seed.s_bid, chap.s_cid)
      cfile = host.chap_file_path(seed.s_bid, chap.s_cid)
      parser = RawRmchap.new(host, cpath: cpath, cfile: cfile, stale: stale)
    else
      return chap.body
    end

    parts = parser.content.split("\n\n")
    chap.save_full!(parts, seed: seed, uname: uname, _flag: 1)

    chap.body
  rescue ex
    Log.error(exception: ex) { ex.message }
    chap.body
  end
end
