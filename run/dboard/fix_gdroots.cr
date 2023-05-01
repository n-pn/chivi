require "../../src/_data/dboard/*"
require "../../src/_data/review/*"

def query_all(kind : CV::Gdroot::Kind)
  CV::Gdroot.db.query_all <<-SQL, kind.value, as: {Int32, String}
    select id, ukey from gdroots where kind = $1 order by id asc
  SQL
end

def fix_dtopic_threads
  query_all(:dtopic).each do |id, ukey|
    next unless dtopic = CV::Dtopic.find({id: ukey.to_i})
    data = CV::Gdroot.new(id, ukey).init_from(dtopic)
    puts data.to_pretty_json
    data.update_orig!
  end
end

def fix_wnovel_threads
  query_all(:wninfo).each do |id, ukey|
    next unless wninfo = CV::Wninfo.find({id: ukey.to_i})
    data = CV::Gdroot.new(id, ukey).init_from(wninfo)
    puts data.to_pretty_json
    data.update_orig!
  end
end

def fix_vicrit_threads
  query_all(:vicrit).each do |id, ukey|
    next unless vicrit = CV::Vicrit.find({id: ukey.to_i})
    data = CV::Gdroot.new(id, ukey).init_from(vicrit)
    puts data.to_pretty_json
    data.update_orig!
  end
end

def fix_vilist_threads
  query_all(:vilist).each do |id, ukey|
    next unless vilist = CV::Vilist.find({id: ukey.to_i})
    data = CV::Gdroot.new(id, ukey).init_from(vilist)
    puts data.to_pretty_json
    data.update_orig!
  end
end

def fix_wnseed_threads
  query_all(:wnseed).each do |id, ukey|
    data = CV::Gdroot.new(id, ukey)
    data.init_as_wnseed_thread
    puts data.to_pretty_json
    data.update_orig!
  end
end

def fix_wnchap_threads
  query_all(:wnchap).each do |id, ukey|
    data = CV::Gdroot.new(id, ukey)
    data.init_as_wnchap_thread
    puts data.to_pretty_json
    data.update_orig!
  end
end

fix_dtopic_threads
fix_wnovel_threads
fix_vicrit_threads
fix_vilist_threads
fix_wnseed_threads
fix_wnchap_threads
