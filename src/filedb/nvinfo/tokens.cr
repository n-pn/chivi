require "./shared"

module CV::NvTokens
  extend self

  TYPES = {
    :author_zh, :author_vi,
    :btitle_zh, :btitle_hv, :btitle_vi,
    :bgenre, :chseed,
  }

  {% for type in TYPES %}
    class_getter {{type.id}} : TokenMap do
      TokenMap.new(NvShared.map_file("tokens/#{{{type}}}"))
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
      @@{{ type.id }}.try(&.save!(mode: mode))
    {% end %}
  end

  def glob(query, matched : Set(String)? = nil)
    if btitle = query["btitle"]?
      matched = glob_btitle(btitle, matched)
      return matched if matched.empty?
    end

    if author = query["author"]?
      matched = glob_author(author, matched)
      return matched if matched.empty?
    end

    if genre = query["genre"]?
      matched = glob_bgenre(genre, matched)
      return matched if matched.empty?
    end

    if bseed = query["bseed"]?
      matched = glob_chseed(bseed, matched)
      return matched if matched.empty?
    end

    matched
  end

  def glob_btitle(query : String, matched : Set(String)? = nil)
    tsv = TextUtils.tokenize(query)
    res = if query =~ /\p{Han}/
            btitle_zh.keys(tsv)
          else
            btitle_hv.keys(tsv) + btitle_vi.keys(tsv)
          end

    matched ? matched & res : res
  end

  def glob_author(query : String, matched : Set(String)? = nil)
    tsv = TextUtils.tokenize(query)
    res = query =~ /\p{Han}/ ? author_zh.keys(tsv) : author_vi.keys(tsv)
    matched ? matched & res : res
  end

  def glob_bgenre(query : String, matched : Set(String)? = nil)
    res = bgenre.keys(TextUtils.slugify(query))
    matched ? matched & res : res
  end

  def glob_chseed(query : String, matched : Set(String)? = nil)
    res = chseed.keys(query.downcase)
    matched ? matched & res : res
  end
end
