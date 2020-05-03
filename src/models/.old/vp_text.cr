require "json"
require "colorize"
require "file_utils"

require "../engine"

class VText < Array(Chivi::Tokens)
  def zh_text(io : IO)
    each do |line|
      line.zh_text(io)
    end
  end

  def vi_text(io : IO)
    each do |line|
      line.vi_text(io)
    end
  end

  def to_s(io : IO)
    to_pretty_json(io)
  end

  def save!(site : String, bsid : String, csid : String)
    save!(VText.file_path(site, bsid, csid))
  end

  def save!(file : String)
    puts "- save chtext to #{file.colorize(:blue)}"
    File.write(file, to_json)
  end

  @@dir = "data/txt-out/chtexts"

  def self.dir
    @@dir
  end

  def self.chdir(dir : String)
    @@dir = dir
  end

  def self.mkdir(site, bsid)
    FileUtils.mkdir_p(File.join(@@dir, site, bsid))
  end

  def self.file_path(site : String, bsid : String, csid : String)
    File.join(@@dir, site, bsid, "#{csid}.json")
  end

  def self.load(site : String, bsid : String, csid : String)
    load(file_path(site, bsid, csid))
  end

  def self.load(file : String)
    return nil unless File.exists?(file)
    from_json(File.read(file))
  end
end
