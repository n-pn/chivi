module CV::DboardACL
  extend self

  def dtopic_create?(dboard : Dboard, cvuser : Cvuser)
    return cvuser.privi > 3 if dboard.id < 0
    cvuser.privi >= 0
  end

  def dtopic_update?(dboard : Dboard, cvuser : Cvuser, dtopic : Dtopic)
    return cvuser.privi > 3 if dboard.id < 0
    cvuser.privi >= 0 && cvuser.id == dtopic.cvuser_id
  end
end
