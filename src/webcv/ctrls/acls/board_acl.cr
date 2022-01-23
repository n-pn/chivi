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

  def dtpost_create?(dtopic : Dtopic, cvuser : Cvuser)
    dtopic.state >= 0 && cvuser.privi >= 0
  end

  def dtpost_update?(dtpost : Dtpost, cvuser : Cvuser)
    return false if cvuser.privi < 0 || dtpost.dtopic.state < 0
    cvuser.id == dtpost.cvuser_id || cvuser.privi > 3
  end
end
