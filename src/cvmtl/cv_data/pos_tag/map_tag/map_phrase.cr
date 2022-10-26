module MT::PosTag
  def self.map_phrase(tag : String)
    case tag
    when "+sv" then make(:subj_verb)
    when "+sa" then make(:subj_adjt)
    when "+pp" then make(:prep_form)
    when "+dp" then make(:dp_phrase)
    when "+dc" then make(:dc_phrase)
    when "+dg" then make(:dg_phrase)
    when "+dr" then make(:dr_phrase)
    when "+dv" then make(:dv_phrase)
    when "+pe" then make(:paren_exp)
    else            make(:lit_trans)
    end
  end
end
