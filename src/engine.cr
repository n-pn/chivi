require "./engine/*"

module Engine
  extend self

  @@repo = CRepo.new("data/dic-out")

  def hanviet(input : String, apply_cap = false)
    Chivi.cv_lit(@@repo.hanviet, input)
  end

  def pinyin(input : String, apply_cap = false)
    Chivi.cv_lit(@@repo.pinyin, input)
  end

  def tradsim(input : String)
    Chivi.cv_raw(@@repo.tradsim, input)
  end

  def translate(input : String, title : Bool, book : String? = nil, user = "admin")
    convert(input, title, book, user).vi_text
  end

  def translate(input : Array(String), mode : Symbol, book : String? = nil, user = "admin")
    convert(input, mode, book, user).map(&.vi_text)
  end

  def convert(input : String, title = false, book : String? = nil, user = "admin")
    dicts = @@repo.for_convert(book, user)
    title ? Chivi.cv_title(dicts, input) : Chivi.cv_plain(dicts, input)
  end

  def convert(lines : Array(String), mode : Symbol, book : String? = nil, user = "admin")
    dicts = @@repo.for_convert(book, user)

    case mode
    when :title
      lines.map { |line| Chivi.cv_title(dicts, line) }
    when :plain
      lines.map { |line| Chivi.cv_plain(dicts, line) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? Chivi.cv_title(dicts, line) : Chivi.cv_plain(dicts, line)
      end
    end
  end
end
