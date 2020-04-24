require "json"
require "../engine"

class VTran
  include JSON::Serializable

  property zh = ""
  property vi = ""
  property hv = ""
  property us = ""

  def initialize(zh = "", vi = "", hv = "", us = "")
    update(zh, vi, hv, us) unless zh.empty?
  end

  def update(@zh = "", @vi = "", @hv = "", @us = "")
    @vi = Engine.convert(@zh).vi_text if @vi.empty?
    @hv = Engine.hanviet(@zh).vi_text if @vi.empty?
    @us = CUtil.slugify(@vi, no_accent: true) if @us.empty?
  end

  def to_s(io : IO)
    io << to_pretty_json
  end
end
