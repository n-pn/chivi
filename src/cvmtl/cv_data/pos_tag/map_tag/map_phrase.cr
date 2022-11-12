module MT::PosTag
  def self.map_phrase(tag : String)
    case tag
    when "Psv" then make(:subj_verb)
    when "Psa" then make(:subj_adjt)
    when "Ppn" then make(:prep_form)
    when "Pdp" then make(:dp_phrase)
    when "Pdc" then make(:dc_phrase)
    when "Pdg" then make(:dg_phrase)
    when "Pdr" then make(:dr_phrase)
    when "Pdv" then make(:dv_phrase)
    when "Ppe" then make(:paren_exp)
    else            make(:lit_trans)
    end
  end
end
