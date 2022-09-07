require "./_base"

class CV::ChapTran
  include Clear::Model

  self.table = "chap_trans"
  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to chroot : Chroot, foreign_key_type: Int32

  column ch_no : Int32

  column part_no : Int16 = 0_i16
  column line_no : Int16 = 0_i16 # line id

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

  def self.trans(chroot : Chroot, ch_no : Int16, part_no : Int16, flag : Int16 = 0)
    query.where({chroot_id: chroot.id, ch_no: ch_no, part_no: part_no, flag: flag})

    trans = {} of Int16 => ChapTran
    query.each { |x| trans[x.line_no] = x }
    trans
  end
end
