require "./*"

class Engine::Main
  def initialize(@dir : String = ".dic")
    @repo = Repo.new(@dir)
  end

  def hanviet(input : String)
    tokens = Core.cv_lit([@repo.hanviet], input)
    to_text(tokens)
  end

  def pinyin(input : String)
    tokens = Core.cv_lit([@repo.pinyin], input)
    to_text(tokens)
  end

  def tradsim(input : String)
    puts "TODO: punctuation!!!"
    tokens = Core.cv_raw([@repo.tradsim], input)
    to_text(tokens)
  end

  def to_text(tokens : Array(Core::Token))
    tokens.map(&.val).join
  end

  def translate(input : String, mode : Symbol = :mixed, book : String? = nil)
    lines = Util.split_lines(input)
    translate(lines, mode, book)
  end

  def translate(lines : Array(String), mode : Symbol, book : String?)
    extra = book ? @repo.unique(book) : @repo.combine
    dicts = [@repo.generic, extra]

    case mode
    when :title
      lines.map { |line| to_text Core.cv_title(dicts, line) }
    when :plain
      lines.map { |line| to_text Core.cv_plain(dicts, line) }
    else # :mixed
      output = [to_text Core.cv_title(dicts, lines.first)]
      lines[1..].each { |line| output << to_text(Core.cv_plain(dicts, line)) }
      output
    end
  end
end
