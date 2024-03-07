require "json"
require "../../_util/http_util"
require "../../_util/file_util"

module SC::ScrapeBase
  property sitename : String        # URI.parse(url).hostname.as(String).lchop("www.")
  property encoding : String? = nil # charset of webpage

  abstract def tmp_path(url : String) : String

  def get_html(url : String, uri = URI.parse(url), ttl : Time = Time.utc - 10.years, use_proxy : Bool = false)
    tmp_path = self.tmp_path(url)
    status = FileUtil.status(tmp_path, ttl)
    return File.read(fpath) if status > 0

    begin
      headers = HttpUtil.gen_headers(url: url, auth: @web_auth, type: :html)
      html = HtmlUtil.fetch(uri: uri, headers: headers, encoding: @encoding, use_proxy: use_proxy)
      File.write(tmp_path, html)
      html
    rescue ex
      raise ex if status < 0
      Log.error(exception: x) { url }
      File.read(fpath)
    end
  end
end

class SC::WnchapRule
  include JSON::Serializable
  include ScrapeBase

  property web_type : Int32 = 0     # 0: alive and easy, 1: alive but need webview, 2: alive but need browser, 3: alive but need special treatment, 4: dead, 5: unique
  property web_auth : String? = nil # Cookie or Authorizaton

  property match_re : String? = nil # test url is valid, extract <bid> and <cid>
  property make_url : String? = nil # fill <div>, <bid> and <cid> to create absolute url

  property title_rule : String = "h1" # extract chap title by css query
  property title_gsub : String? = nil # cleanup chap title by regex

  property cbody_rule : String = "#content" # extract chap body by css query
  property cbody_gsub : String? = nil       # cleanup chap body by regex

  property bname_rule : String? = nil # extract book name by css query
  property bname_gsub : String? = nil # cleanup book name by regex

  property csucc_rule : String? = nil # get next chapter url by css query
  property cprev_rule : String? = nil # get previous chapter url by css query
  property cstem_rule : String? = nil # get chapter index page url by css query

  property _uname : String = ""              # last modified by this user
  property _mtime : Int64 = Time.utc.to_unix # last modified at

  def initialize(@sitename)
  end

  @[JSON::Field(ignore: true)]
  getter bid_cid_re : Regex { Regex.new(@match_re || "(\\d+)\\D+(\\d+)\\D*$") }

  def tmp_path(url : String) : String
    _, bid, cid = self.bid_cid_re.match!(url)
    "#{SAVE_DIR}/#{@sitename}/#{bid}/#{cid}.htm"
  end

  ###
  #
  SAVE_DIR = "var/.keep/rmchap"
  RULE_DIR = "var/_conf/scrape_rules"

  def self.rule_path(sitename : String)
    "#{RULE_DIR}/#{sitename}-wnchap.json"
  end

  RULES = {} of String => self

  def self.load_rule(sitename : String)
    RULES[sitename] ||= begin
      path = self.rule_path(sitename)
      from_json(File.read(path)) rescue new(sitename)
    end
  end
end
