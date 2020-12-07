require "./library"
require "./convert/*"

class Chivi::Convert
  class_getter hanviet : self { new(Library.hanviet) }
  class_getter binh_am : self { new(Library.binh_am) }
  class_getter tradsim : self { new(Library.tradsim) }

  MACHINES = {} of String => self

  def self.content(udict : String)
    MACHINES[udict] ||= new(Library.regular, Library.find_dict(udict))
  end

  def initialize(@bdict : VpDict, @udict : VpDict? = nil)
  end

  def translit(input : String, apply_cap : Bool = false)
    group = tokenize(input)
    group.capitalize! if apply_cap
    group.pad_spaces!
  end

  def cv_plain(input : String)
    tokenize(input.chars).fix_grammar!.capitalize!.pad_spaces!
  end

  private def tokenize(chars : Array(Char))
    token = CvToken.new(chars)

    token.size.times do |caret|
      token.weighing(@bdict, caret)
      token.weighing(@udict, caret) if @udict
    end

    token.to_group
  end
end
