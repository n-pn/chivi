require "diff"

module DiffUtil
  def self.diff_json(old_text : String, new_text : String)
    XDiff.diff(old_text, new_text).map { |x| {x.type.value, x.data} }.to_json
  end
end
