require "./nv_helper"
require "./nv_chseed"

module CV::NvTokens
  extend self

  TYPES = {
    :author_zh, :author_vi,
    :btitle_zh, :btitle_hv, :btitle_vi,
    :genres,
  }

  {% for type in TYPES %}
    class_getter {{type.id}} : TokenMap do
      TokenMap.new(NvHelper.map_file("tokens/#{{{type}}}"))
    end

    def set_{{type.id}}(key : String, vals : Array(String))
      vals.map{|v| TextUtils.slugify(v)}.tap do |arr|
        {{type.id}}.upsert(key, arr)
      end
    end

    def set_{{type.id}}(key : String, vals : String)
      TextUtils.tokenize(vals).tap do |arr|
        {{type.id}}.upsert(key, arr)
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

    if sname = query["sname"]?
      matched = NvChseed.glob(sname, matched)
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
    res = genres.keys(TextUtils.slugify(query))
    matched ? matched & res : res
  end
end
