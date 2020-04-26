# require "file_utils"

module Utils
  INP_DIR = "data/txt-inp"

  def self.info_dir(site : String)
    File.join(INP_DIR, site, "infos")
  end

  def self.info_path(site : String, bsid : String)
    File.join(info_dir(site), "#{bsid}.html")
  end

  def self.text_dir(site : String, bsid : String)
    File.join(INP_DIR, site, "texts", bsid)
  end

  def self.text_path(site : String, bsid : String, csid : String)
    File.join(text_dir(site, bsid), "#{csid}.html")
  end

  def self.read_file(file : String, expiry : Time | Time::Span)
    return if outdated?(file, expiry)
    File.read(file)
  end

  def self.outdated?(file : String, span : Time::Span)
    outdated?(file, Time.utc - span)
  end

  def self.outdated?(file : String, etag : Time = Time.utc - 3.hours)
    return true unless File.exists?(file)
    etag > File.info(file).modification_time
  end
end
