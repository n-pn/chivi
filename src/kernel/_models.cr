require "clear"
require "../engine/convert"
require "../shared/seed_utils"

Clear::SQL.init("postgres://postgres:postgres@localhost/chivi")

module Chivi::ModelUtils
  extend self

  def to_hanviet(input : String, as_title : Bool = false)
    output = Convert.hanviet.translit(input, false).to_text
    as_title ? SeedUtils.titleize(output) : output
  end

  delegate tokenize, to: SeedUtils
end
