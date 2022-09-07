require "./_base"

class CV::ChapEdit
  include Clear::Model

  self.table = "chap_edits"
  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to chroot : Chroot, foreign_key_type: Int32

  column chidx : Int16
  column schid : String
  column cpart : Int16 = 0_i16

  column l_id : Int16 = 0_i16 # line id
  column orig : String = ""   # original text line
  column edit : String        # edited text line

  # flag:  an enum to denote the state of this edit
  # 0: accepted and active
  # 1: accepted but outdated
  # 2: pending / await approve
  #    in some case when you edit text from source that you do not have priviledge
  # 3: rejected. not approved by moderators...
  # 4: mark as deleted

  column flag : Int16 = 0

  timestamps
end
