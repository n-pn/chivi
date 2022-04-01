module CV::DboardACL
  extend self

  def dtopic_create?(nvinfo : Nvinfo, cvuser : Cvuser)
    nvinfo.id < -1 ? cvuser.privi > 3 : cvuser.privi >= 0
  end

  def dtopic_update?(dtopic : Cvpost, cvuser : Cvuser)
    cvuser.privi > 3 || cvuser.privi >= 0 && cvuser.id == dtopic.cvuser_id
  end

  def dtpost_create?(dtopic : Cvpost, cvuser : Cvuser)
    dtopic.state >= 0 && cvuser.privi >= 0
  end

  def dtpost_update?(dtpost : Cvrepl, cvuser : Cvuser)
    return false if cvuser.privi < 0 || dtpost.dtopic.state < 0
    cvuser.id == dtpost.cvuser_id || cvuser.privi > 3
  end
end
