require "../../_init/postag_init"

class CV::VpinitCtrl < CV::BaseCtrl
  DIR = "var/inits/dicts"

  def fixtag
    source = params["source"]
    target = params["target"]
    limit = params.read_int("limit", min: 50, max: 200)

    init_data = PostagInit.new("#{DIR}/_init/#{source}")
    conflicts = extract_conflicts(init_data, VpDict.load(target), limit)

    send_json({data: conflicts, source: source, target: target})
  end

  def upsert
    return halt! 400, "Not authorized" if _viuser.privi < 3

    key = params["key"]
    val = params["val"]
    tag = params["tag"]

    vpterm = VpTerm.new(key, [val], tag, uname: _viuser.uname, mtime: 0)
    result = @@topatch.set!(vpterm)

    send_json({result: result})
  end

  @@similar = VpDict.new("#{DIR}/patch/similar-tags.tsv", kind: :basic)
  @@topatch = VpDict.new("#{DIR}/patch/topatch-tags.tsv", kind: :basic)

  private def extract_conflicts(postag : PostagInit, target : VpDict, limit = 200)
    conflicts = [] of Conflict

    postag.data.each do |key, counts|
      next if @@topatch.find(key) || @@similar.find(key)
      ptag = counts.first_key

      next unless term = target.find(key)

      if similar?(term.attr, ptag)
        @@similar.set(VpTerm.new(key, term.val, term.attr, mtime: 0))
      else
        # next if PFR14.includes?(key)

        if attr = fix_ptag?(term, ptag)
          @@topatch.set!(VpTerm.new(key, term.val, attr, mtime: 0))
        else
          conflicts << Conflict.new(term, counts)
          break if conflicts.size >= limit
        end
      end
    end

    @@similar.save!
    conflicts
  end

  record Conflict, term : VpTerm, ptags : PostagInit::CountTag do
    def to_json(jb)
      {
        attr:  term.attr,
        key:   term.key,
        val:   term.val[0],
        uname: term.uname,
        mtime: term.utime,
        ptags: ptags,
      }.to_json(jb)
    end
  end

  def similar?(attr : String, ptag : String)
    return true if attr == "na"
    return false unless char = attr[0]?

    case ptag
    when "nx" then char == "n" || char == "nz"
    when "n"  then char == 'n' || attr == "kn"
    when "a"  then char == 'b' || attr.in?("a", "al")
    when "xc" then attr.in?("o", "y", "e")
    else           char == ptag[0]
    end
  end

  def fix_ptag?(term : VpTerm, ptag : String) : String?
    attr = term.attr
    return ptag if attr.in?("", "i", "l", "j")

    fval = term.val.first
    not_name = fval.downcase == fval || term.uname == "[hv]"

    case ptag
    when "nn"
      return ptag if attr.in?("ns", "nt", "n", "nz")
      return ptag if attr.in?("v") && !not_name
    when "t", "s"
      return ptag if attr == "n"
    when "nz"
      return ptag if attr == "n"
    when "a"
      return "al" if attr.in?("vl", "bl", "az", "z") || term.key =~ /.(.)\1/
    when "ad"
      return ptag if attr.in?("a", "d")
    when "an"
      return ptag if attr.in?("a", "n")
    when "vd"
      return ptag if attr.in?("v", "vd")
    when "vn"
      return ptag if attr.in?("v", "n")
    when "Nr"
      return not_name ? nil : ptag
      # when "v"
      # return "vn" if attr.in?("n")
    when "m"
      return "mq" if attr.in?("q", "n", "t")
    end

    case attr
    when "b", "bl", "an", "al"
      return "na" if ptag == "n"
    when "nr", "ns", "nt"
      return ptag if not_name
    when "nz"
      return ptag if not_name && ptag.in?("n", "v", "a")
    when "ng"
      return ptag if ptag.in?("n", "an", "vn")
    when "ag"
      return ptag if ptag.in?("a", "an", "ad")
    when "vg"
      return ptag if ptag.in?("v", "vd", "vn")
    else
      nil
    end
  end
end
