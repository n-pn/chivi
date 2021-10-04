require "../src/libcv/vp_dict"

def clean(dict : CV::VpDict)
  dict.data.each do |term|
    next unless term.uname == "[hv]"
    term._flag = 2_u8
    CV::VpDict.suggest.set(CV::VpDict.suggest.new_term(term)) if dict.dtype == 2
  end

  dict.save!
end

clean(CV::VpDict.regular)

CV::VpDict.udicts.each do |dname|
  clean(CV::VpDict.load(dname))
end

CV::VpDict.suggest.save!
