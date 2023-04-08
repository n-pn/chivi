class MT::NerCore
  @[Flags]
  enum Opts
    Enabled
    Persist
  end

  def initialize
  end

  def fetch_all(ner_chars : Array(Char), raw_chars = ner_chars, &)
    # TODO
  end

  class_getter translit : self { new }
end
