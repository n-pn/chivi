class CV::Cttran
  include Clear::Model

  self.table = "cttrans"
  belongs_to chinfo : Chinfo, foreign_key_type: Int32, primary: true, presence: true

  column title : String = ""
  column chvol : String = ""
  column uslug : String = ""

  column fixed : Bool = false
  timestamps

  def initialize(chinfo : Chinfo, engine : MtCore?)
    @persisted = false
    engine ||= chinfo.chroot.nvinfo.cvmtl
    autogen(chinfo.title, chinfo.chvol, engine)
  end

  def autogen(zh_title, zh_chvol, engine)
    self.title = zh_title.empty? ? "Thiếu chương" : engine.cv_title(zh_title).to_txt
    self.chvol = zh_chvol.empty? ? "Chính văn" : engine.cv_title(zh_chvol).to_txt
    self.uslug = slugify(self.title)
  end

  def slugify(title : String)
    tokens = TextUtil.tokenize(title)

    if tokens.size > 8
      tokens.truncate(0, 8)
      tokens[7] = ""
    end

    tokens.join("-")
  end
end
