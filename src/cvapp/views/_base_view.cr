require "json"

module CV::BaseView
  def to_json(io : IO)
    JSON.build(io) { |jb| to_json(jb) }
  end

  abstract def to_json(jb : JSON::Builder)
end
