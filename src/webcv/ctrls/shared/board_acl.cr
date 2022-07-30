module CV::DboardACL
  extend self

  def cvpost_create?(nvinfo : Nvinfo, viuser : Viuser)
    nvinfo.id < -1 ? viuser.privi > 3 : viuser.privi >= 0
  end

  def cvpost_update?(cvpost : Cvpost, viuser : Viuser)
    viuser.privi > 3 || viuser.privi >= 0 && viuser.id == cvpost.viuser_id
  end

  def cvrepl_create?(cvpost : Cvpost, viuser : Viuser)
    cvpost.state >= 0 && viuser.privi >= 0
  end

  def cvrepl_update?(cvrepl : Cvrepl, viuser : Viuser)
    return false if viuser.privi < 0 || cvrepl.cvpost.state < 0
    viuser.id == cvrepl.viuser_id || viuser.privi > 3
  end
end
