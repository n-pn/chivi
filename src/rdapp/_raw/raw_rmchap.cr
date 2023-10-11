require "./_remote"

class RawRmchap
  ####

  def self.from_link(full_link : String, stale : Time = Time.utc - 1.years)
    host, cpath = URI.parse(full_link).try { |x| {x.host, x.path} }
    host = Rmhost.from_host!(host.as(String))

    b_id, c_id = host.extract_ids(cpath)
    cfile = host.chap_file(b_id, c_id)

    new(host, cpath, cfile, stale)
  end

  def self.from_path(sname : String, b_id : String | Int32, cpath : String,
                     stale : Time = Time.utc - 1.years)
    host = Rmhost.from_name!(sname)
    cfile = host.chap_file(b_id, cid: host.extract_cid(cpath))

    new(host, cpath, cfile, stale)
  end

  def self.from_seed(sname : String, b_id : String | Int32, c_id : String | Int32,
                     stale = Time.utc - 1.years)
    host = Rmhost.from_name!(sname)

    cpath = host.chap_href(b_id, c_id)
    cfile = host.chap_file(b_id, c_id)

    new(host, cpath, cfile, stale)
  end

  private def self.load_decrypt_string(host : Rmhost, cpath : String, cfile : String)
    tfile = cfile.sub(".htm", ".tok")
    return File.read(tfile) if File.file?(tfile)

    tpath = cpath.sub(/(\d+).html$/) { "r#{$1}.json" }

    host.http_client.get(tpath, headers: host.xhr_headers(cpath)) do |res|
      raise "Can't download decode string" unless res.success?
      res.headers["token"].tap { |x| File.write(tfile, x) }
    end
  end

  def self.new(host : Rmhost, cpath : String, cfile : String, stale : Time)
    Dir.mkdir_p(File.dirname(cfile))

    html = host.load_page(cpath, cfile, stale: stale)
    extra = host.chap_type == "encrypt" ? load_decrypt_string(host, cpath, cfile) : ""

    new(html, host, extra)
  end

  ###

  getter title = ""
  getter paras = [] of String

  def initialize(html : String, @host : Rmhost, @extra = "")
    @page = Rmpage.new(html)
  end

  def extract_title(selector : String)
    elem = @page.find!(selector)
    elem.children.each { |node| node.remove! if node.tag_sym == :a }

    title = @page.inner_text(elem, ' ')
      .sub(/^\d+\.第/, "第")
      .sub(/(^章节目录|(《.+》)?正文)/, "")

    TextUtil.canon_clean(title)
  end

  def extract_paras(chap_type : String, selector : String)
    case chap_type
    when "encrypt" then extract_encrypt_paras(selector)
    else                extract_generic_paras(selector)
    end
  end

  private def extract_generic_paras(selector : String)
    return @paras unless container = @page.find(selector)

    container.children.each do |node|
      case node.tag_sym
      when :script, :div, :h1, :table, :ul, :a
        node.remove!
      when :p
        node.remove! if node.attributes["style"]? || node.attributes["class"]? == "readinline"
      end
    end

    scrub_re = @host.chap_body_scrub.try { |x| Regex.new(x) }

    container.inner_text('\n').each_line do |line|
      scrub_re.try { |re| line = line.sub(re, "") }

      line = TextUtil.canon_clean(line)
      next if line.empty?

      @paras << line
    end

    @paras.shift if invalid_first_line?(@paras.first? || "")
    @paras.pop if @paras.last? == "（本章完）"

    @paras
  end

  private def invalid_first_line?(line : String)
    # TODO: remove /^，#{bname}/ ?

    line =~ /笔趣阁|笔下文学/ || line.sub(@title, "") !~ /\p{Han}/
  end

  private def extract_encrypt_paras(selector : String)
    reorder = Base64.decode_string(@extra).split(/[A-Z]+%/).map(&.to_i)

    @paras = Array(String).new(reorder.size, "")
    jmp = 0

    @page.css(selector).each_with_index do |node, idx|
      ord = reorder[idx]? || 0

      if ord < 5
        jmp += 1
      else
        ord -= jmp
      end

      @paras[ord] = TextUtil.canon_clean(node.inner_text(deep: false))
    end

    @paras
  end

  def parse_page!
    @title = extract_title(@host.chap_name)
    @paras = extract_paras(@host.chap_type, @host.chap_body)

    {@title, @paras}
  end
end
