require "kemal"

require "../engine"
require "../kernel"

module Server::Utils
  def self.parse_page(input, limit = 20)
    page = input.to_i? || 0

    offset = (page - 1) * limit
    offset = 0 if offset < 0

    {limit, offset}
  end

  def self.json_error(msg : String)
    {msg: msg}.to_json
  end
end
