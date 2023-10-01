module RD::RD_ENV
  WN_TXT_DIR = "var/wnapp/chtext"
  UP_TXT_DIR = "var/up_db/texts"
  RM_TXT_DIR = "var/rm_db/texts"

  WN_DB3_DIR = "var/wnapp/chinfo"
  UP_DB3_DIR = "var/up_db/stems"
  RM_DB3_DIR = "var/rm_db/stems"
end

enum RD::Rdtype : Int8
  NC; UP; RM

  def txt_path(fpath : String) : String
    case self
    in NC then "#{RD_ENV::WN_TXT_DIR}/#{fpath}"
    in UP then "#{RD_ENV::UP_TXT_DIR}/#{fpath}"
    in RM then "#{RD_ENV::RM_TXT_DIR}/#{fpath}"
    end
  end

  def db3_path(sname : String, sn_id : String | Int32, dtype : String = "cinfo")
    case self
    in NC then "#{RD_ENV::WN_DB3_DIR}/#{sname}/#{sn_id}.db3"
    in UP then "#{RD_ENV::UP_DB3_DIR}/#{sname}/#{sn_id}-#{dtype}.db3"
    in RM then "#{RD_ENV::RM_DB3_DIR}/#{fpath}/#{sn_id}-#{dtype}.db3"
    end
  end
end
