require "../../src/mt_v2/vp_dict"

INP = "var/inits/dicts/patch"

def patch_dict(source : String, target : CV::VpDict, dry_run = false)
  CV::VpDict.new(source).list.each do |term|
    next if term._flag > 0

    if !(old_term = target.find(term.key))
      puts "- [#{term.key} = #{term.val.first}] #{term.attr}".colorize.green
      target.set(term)
    elsif old_term.attr != term.attr
      puts "- [#{term.key} = #{term.val.first}] #{old_term.attr} => #{term.attr}".colorize.yellow
      old_term.force_fix!(old_term.val, term.attr)
    else
      puts "- [#{term.key} = #{term.val.first}] #{term.attr}".colorize.dark_gray
    end
  end

  target.save! unless dry_run
end

# patch_dict("#{INP}/topatch-tags.tsv", CV::VpDict.regular)
patch_dict("#{INP}/similar-tags.tsv", CV::VpDict.regular, dry_run: true)
