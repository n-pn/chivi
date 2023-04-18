require "compress/zip"
require "log"

module WN::TextStore
  extend self

  def get_chap(seed : WnSeed, chap : WnChap)
    txt_path = gen_txt_path(seed.sname, seed.s_bid, chap.s_cid)

    File.file?(txt_path) ? read_txt_file(txt_path) : [""]

    # try reading txt file from new zip
    # read_txt_from_zip(seed, chap).try { |x| return x }

    # _path = chap._path

    # # return blank data if no backend link found
    # return [""] unless _path[0]? == '!'

    # # try reading txt file from backend txt folder
    # bg_path = _path.split(':')[0]

    # bg_txt_path = gen_txt_path(bg_path)
    # return read_txt_file(bg_txt_path) if File.file?(bg_txt_path)

    # # reading txt file from backend zip folder
    # bg_sname, bg_s_bid, bg_s_cid = bg_path.split('/')
    # bg_zip_path = gen_zip_path(bg_sname, bg_s_bid.to_i)

    # read_txt_from_zip(bg_zip_path, bg_s_cid.to_i)
  end

  TXT_DIR = "var/texts/rgbks"

  # generate body text path to be saved
  @[AlwaysInline]
  def gen_txt_path(sname : String, s_bid : Int32, s_cid : Int32) : String
    gen_txt_path("#{sname}/#{s_bid}/#{s_cid}")
  end

  # :ditto:
  @[AlwaysInline]
  def gen_txt_path(bg_path : String) : String
    "#{TXT_DIR}/#{bg_path}.gbk"
  end

  ENCODING = "GB18030"

  # read chap text file and split to parts
  @[AlwaysInline]
  def read_txt_file(txt_path : String)
    # Log.info { "found in txt folder: #{txt_path}" }
    body = File.read(txt_path, encoding: ENCODING)
    body.empty? ? [""] : body.split("\n\n")
  end

  # save chap text file with body parts provided
  @[AlwaysInline]
  def save_txt_file(seed : WnSeed, chap : WnChap) : String
    txt_path = gen_txt_path(seed.sname, seed.s_bid, chap.s_cid)
    save_txt_file(txt_path, chap.body)
  end

  # :ditto:
  @[AlwaysInline]
  def save_txt_file(txt_path : String, body_parts : Array(String)) : String
    body = body_parts.join("\n\n").encode(ENCODING)
    File.write(txt_path, body, encoding: ENCODING)
    txt_path
  end

  def zip_one(sname : String, s_bid : Int32, txt_path : String) : Nil
    zip_path = gen_zip_path(sname, s_bid)
    Dir.mkdir_p(File.dirname(zip_path))

    `zip -jyoq '#{zip_path}' '#{txt_path}'`
  end

  def zip_all(sname : String, s_bid : Int32) : Nil
    zip_path = gen_zip_path(sname, s_bid)
    Dir.mkdir_p(File.dirname(zip_path))

    text_dir = "#{TXT_DIR}/#{sname}/#{s_bid}"
    `zip -FSrjyoq '#{zip_path}' '#{text_dir}'`
  end

  #############

  ZIP_DIR = "var/texts/rzips"

  def unload_zip!(sname : String, s_bid : Int32) : Nil
    unload_zip!(gen_zip_path(sname, s_bid))
  end

  def unload_zip!(zip_path : String) : Nil
    not_found = zip_path + ".404"
    return if File.file?(zip_path) || File.file?(not_found)
    File.touch(not_found) unless pull_zip_from_b2!(zip_path)
  end

  # generate zip path
  @[AlwaysInline]
  def gen_zip_path(seed : WnSeed)
    gen_zip_path(seed.sname, seed.s_bid)
  end

  # :ditto:
  @[AlwaysInline]
  def gen_zip_path(sname : String, s_bid : Int32)
    "#{ZIP_DIR}/#{sname}/#{s_bid}.zip"
  end

  # read text from zip file
  @[AlwaysInline]
  def read_txt_from_zip(seed : WnSeed, chap : WnChap)
    read_txt_from_zip(gen_zip_path(seed), chap.s_cid)
  end

  # :ditto
  def read_txt_from_zip(zip_path : String, s_cid : Int32) : Array(String)?
    return nil if File.file?(zip_path + ".404")

    unless File.file?(zip_path) || pull_zip_from_b2!(zip_path)
      File.touch(zip_path + ".404")
      return nil
    end

    Compress::Zip::File.open(zip_path) do |zip|
      return unless entry = zip["#{s_cid}.gbk"]?
      # Log.info { "found in zip archive: #{zip_path}" }

      entry.open do |io|
        io.set_encoding ENCODING
        io.gets_to_end.split("\n\n")
      end
    rescue ex
      File.delete?(zip_path)
      Log.error(exception: ex) { ex.message }
      nil
    end
  end

  B2_URL = "https://f004.backblazeb2.com/file/cvtxts"

  # download zip from backblaze b2 object storage
  private def pull_zip_from_b2!(file : String) : Bool
    Dir.mkdir_p(File.dirname(file))

    link = file.sub(ZIP_DIR, B2_URL)

    HTTP::Client.get(link) do |res|
      return false unless res.success?
      File.write(file, res.body_io)
    end

    unzip_file(file)
    true
  end

  private def unzip_file(file : String)
    out_dir = file.sub(ZIP_DIR, TXT_DIR).sub(".zip", "")
    Process.run("unzip", args: {"-nq", file, "-d", out_dir})
  rescue ex
    Log.error(exception: ex) { ex.message }
  end
end
