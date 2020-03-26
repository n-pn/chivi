require "./engine/*"

module Engine
  extend self

  @@repo = CvRepo.new(".dic")

  def hanviet(input : String, apply_cap = false)
    CvCore.cv_lit(@@repo.hanviet, input)
  end

  def pinyin(input : String, apply_cap = false)
    CvCore.cv_lit(@@repo.pinyin, input)
  end

  def tradsim(input : String)
    CvCore.cv_raw(@@repo.tradsim, input)
  end

  def convert(input : String, title = false, book : String? = nil, user = "admin")
    dicts = @@repo.for_convert(book, user)
    title ? CvCore.cv_title(dicts, input) : CvCore.cv_plain(dicts, input)
  end

  def convert(lines : Array(String), mode : Symbol, book : String? = nil, user = "admin")
    dicts = @@repo.for_convert(book, user)

    case mode
    when :title
      lines.map { |line| CvCore.cv_title(dicts, line) }
    when :plain
      lines.map { |line| CvCore.cv_plain(dicts, line) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? CvCore.cv_title(dicts, line) : CvCore.cv_plain(dicts, line)
      end
    end
  end

  def to_text(tokens : Array(CvCore::Token))
    String.build { |io| to_text(tokens, io) }
  end

  def to_text(tokens : Array(CvCore::Token), io : IO)
    tokens.each { |token| io << token.val }
  end
end
