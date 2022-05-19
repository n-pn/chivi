module CV::DboardACL
  extend self

  def cvpost_create?(nvinfo : Nvinfo, cvuser : Cvuser)
    nvinfo.id < -1 ? cvuser.privi > 3 : cvuser.privi >= 0
  end

  def cvpost_update?(cvpost : Cvpost, cvuser : Cvuser)
    cvuser.privi > 3 || cvuser.privi >= 0 && cvuser.id == cvpost.cvuser_id
  end

  def cvrepl_create?(cvpost : Cvpost, cvuser : Cvuser)
    cvpost.state >= 0 && cvuser.privi >= 0
  end

  def cvrepl_update?(cvrepl : Cvrepl, cvuser : Cvuser)
    return false if cvuser.privi < 0 || cvrepl.cvpost.state < 0
    cvuser.id == cvrepl.cvuser_id || cvuser.privi > 3
  end
end
