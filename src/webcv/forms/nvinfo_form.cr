struct CV::NvinfoForm
  getter params : Amber::Validators::Params
  getter errors : String = ""

  getter btitle_zh : String
  getter author_zh : String

  def initialize(@params)
    @btitle_zh = get_param("btitle_zh").not_nil!
    @author_zh = get_param("author_zh").not_nil!
  end

  def get_param(name : String)
    return unless value = params["name"]?
    value = TextUtil.fix_spaces(value).strip
    value unless value.empty?
  end

  def get_author(author_zh : String)
    author_vi = get_param("author_vi")
    BookUtil.vi_authors.append!(author_zh, author_vi) if author_vi
    Author.upsert!(author_zh, author_vi)
  end

  def get_btitle(btitle_zh : String)
    btitle_vi = get_param("btitle_vi")
    BookUtil.vi_btitles.append!(btitle_zh, btitle_vi) if btitle_vi
    Btitle.upsert!(btitle_zh, btitle_vi)
  end

  def save(uname = "users") : Nvinfo?
    btitle_zh, author_zh = BookUtil.fix_names(@btitle_zh, @author_zh)

    author = get_author(author_zh)
    btitle = get_btitle(btitle_zh)

    nvinfo = Nvinfo.upsert!(author, btitle, fix_names: true)
    nvseed = Nvseed.upsert!(nvinfo, uname, nvinfo.bhash)

    if bintro = get_param("bintro")
      bintro = TextUtil.split_html(bintro, true)
      nvseed.set_bintro(bintro, mode: 2)
    end

    if genres = get_param("genres").try(&.split(","))
      genres.map!(&.strip)
      nvinfo.igenres = GenreMap.map_int(genres)
      nvseed.set_genres(GenreMap.vi_to_zh(genres), mode: 1)
    end

    if bcover = params["bcover"]?
      bcover = TextUtil.fix_spaces(bcover).strip
      nvseed.set_bcover(bcover, mode: 2)
    end

    if status = params["status"]?
      status = TextUtil.fix_spaces(status).strip.to_i
      nvseed.set_status(status, mode: 2)
    end

    nvseed.nvinfo = nvinfo
    nvseed.btitle = @btitle_zh
    nvseed.author = @author_zh

    nvinfo.save!
    nvseed.save!

    nvinfo
  rescue err
    @errors = err.message || "Unknown error"
    nil
  end

  def after_save
    Nvinfo.cache!(nvinfo)

    spawn do
      `bin/bcover_cli "#{nvinfo.scover}" #{nvinfo.bcover} users`
      body = params.to_unsafe_h.tap(&.delete("_json"))
      CtrlUtil.log_user_action("nvinfo-upsert", body, _cvuser.uname)
    end
  end
end
