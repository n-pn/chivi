class CV::Chtran
  include Clear::Model

  self.table = "chtrans"
  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to nvseed : Nvseed

  column chidx : Int16
  column schid : String
  column cpart : Int16 = 0_i16

  column l_id : Int16 = 0_i16 # line id

  column orig : String = "" # original text line
  column tran : String      # translation

  # flag:  an enum to denote the state of this translation
  # 0: accepted and active
  # 1: accepted but outdated
  # 2: pending / await approve
  #    in some case when you add translation from source that you do not have priviledge
  # 3: rejected. not approved by moderators...
  # 4: mark as deleted
  column flag : Int16 = 0

  timestamps

  # ## load all translation for this chapter part

  def self.trans(nvseed : Nvseed, chidx : Int16, cpart : Int16, flag : Int16 = 0)
    query.where({nvseed_id: nvseed.id, chidx: chidx, cpart: cpart, flag: flag})

    trans = {} of Int16 => Chtran
    query.each { |x| trans[x.l_id] = x }
    trans
  end
end
