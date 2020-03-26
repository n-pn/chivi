require "./engine/*"

module Engine
  extend self

  @@repo = Repo.new(".dic")

  def hanviet(input : String, apply_cap = false)
    Core.cv_lit([@@repo.hanviet], input)
  end

  def pinyin(input : String, apply_cap = false)
    Core.cv_lit([@@repo.pinyin], input)
  end

  def tradsim(input : String)
    Core.cv_raw([@@repo.tradsim], input)
  end

  def convert(input : String, title = false, book : String? = nil)
    extra = book ? @@repo.unique(book) : @@repo.combine
    dicts = [@@repo.generic, extra]
    title ? Core.cv_title(dicts, input) : Core.cv_plain(dicts, input)
  end

  def convert(lines : Array(String), mode : Symbol, book : String?)
    extra = book ? @@repo.unique(book) : @@repo.combine
    dicts = [@@repo.generic, extra]

    case mode
    when :title
      lines.map { |line| Core.cv_title(dicts, line) }
    when :plain
      lines.map { |line| Core.cv_plain(dicts, line) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? Core.cv_title(dicts, line) : Core.cv_plain(dicts, line)
      end
    end
  end

  def to_text(tokens : Array(Core::Token))
    String.build { |io| to_text(tokens, io) }
  end

  def to_text(tokens : Array(Core::Token), io : IO)
    tokens.each { |token| io << token.val }
  end
end
