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
    to_text convert(input, title, book, user)
  end

  def translate(input : Array(String), mode : Symbol, book : String? = nil, user = "admin")
    convert(input, mode, book, user).map do |tokens|
      to_text tokens
    end
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

  def to_text(tokens : Array(Chivi::Token))
    String.build { |io| to_text(tokens, io) }
  end

  def to_text(tokens : Array(Chivi::Token), io : IO)
    tokens.each { |token| io << token.val }
  end
end
