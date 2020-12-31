require "./_utils"

module CV::Nvinfo::Tokens
  extend self

  TYPES = {
    :author_zh, :author_vi,
    :btitle_zh, :btitle_hv, :btitle_vi,
    :bgenre, :chseed,
  }

  {% for type in TYPES %}
    class_getter {{type.id}} : TokenMap do
      TokenMap.new(Utils.map_file("tokens/#{{{type}}}"))
    end

    def set_{{type.id}}(key : String, vals : Array(String))
      vals.map{|v| TextUtils.slugify(v)}.tap do |arr|
        {{type.id}}.set(key, arr)
      end
    end

    def set_{{type.id}}(key : String, vals : String)
      TextUtils.tokenize(vals).tap do |arr|
        {{type.id}}.set(key, arr)
      end
    end
  {% end %}

  def save!(mode : Symbol = :full)
    {% for type in TYPES %}
      @@{{ type.id }}.try(&.save!(mode))
    {% end %}
  end

  def glob(btitle = "", author = "", genre = "", bseed = "", res : Set(String)? = nil)
    unless btitle.empty?
      res = glob_btitle(btitle, res)
      return res if res.empty?
    end

    unless author.empty?
      res = glob_author(author, res)
      return res if res.empty?
    end

    unless genre.empty?
      res = glob_bgenre(genre, res)
      return res if res.empty?
    end

    unless bseed.empty?
      res = glob_chseed(bseed, res)
      return res if res.empty?
    end

    res
  end

  def glob_btitle(query : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(query)
    res = if query =~ /\p{Han}/
            btitle_zh.keys(tsv)
          else
            btitle_hv.keys(tsv) + btitle_vi.keys(tsv)
          end

    prevs.try(&.&(res)) || res
  end

  def glob_author(query : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(query)
    res = query =~ /\p{Han}/ ? author_zh.keys(tsv) : author_vi.keys(tsv)
    prevs.try(&.&(res)) || res
  end

  def glob_bgenre(query : String, prevs : Set(String)? = nil)
    res = bgenre.keys(TextUtils.slugify(query))
    prevs.try(&.&(res)) || res
  end

  def glob_chseed(query : String, prevs : Set(String)? = nil)
    res = chseeed.keys(query.downcase)
    prevs.try(&.&(res)) || res
  end
end
