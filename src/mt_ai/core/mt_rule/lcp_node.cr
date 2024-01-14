# require "./ai_term"

class MT::AiCore
  def init_lcp_term(orig : String, attr : MtAttr, from = 0)
    @dicts.each { |d| d.get?(zstr, epos).try { |x| return x } }
  end

  def init_lcp_term(orig : Array(RawCon), attr : MtAttr, from = 0)
    raise "todo!"
  end
end
