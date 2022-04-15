require "./_base_ctrl"
require "../../_init/postag_init"

class CV::VpinitCtrl < CV::BaseCtrl
  def fixtag
    source = params["source"]
    target = params["target"]

    init_data = PostagInit.load(source, fixed: true)
    conflicts = init_data.match(target)
    send_json({data: conflicts, source: source, target: target})
  end

  def upsert
    return halt! 400, "Not authorized" if _cvuser.privi < 3

    key = params["key"]
    val = params["val"]
    tag = params["tag"]

    vpterm = VpTerm.new(key, [val], tag, uname: _cvuser.uname, mtime: 0)
    result = PostagInit.topatch.set!(vpterm)

    send_json({result: result})
  end
end
