module WN::TextStore
  extend self

  # generate body text path to be saved
  @[AlwaysInline]
  def gen_txt_path(seed : WnSeed, chap : WnChap)
    gen_txt_path(seed.sname, seed.s_bid, chap.s_cid)
  end

  TXT_DIR = "var/chaps/temps"

  # :ditto:
  @[AlwaysInline]
  def gen_txt_path(sname : String, s_bid : Int32, s_cid : Int32) : String
    "#{TXT_DIR}/#{sname}/#{s_bid}/#{s_cid}.txt"
  end

  # :ditto:
  @[AlwaysInline]
  def gen_txt_path(bg_path : String) : String
    "#{TXT_DIR}/#{bg_path}.txt"
  end

  # read chap text file and split to parts
  @[AlwaysInline]
  def read_txt_file(seed : WnSeed, chap : WnChap)
    read_txt_file(gen_txt_path(seed, chap))
  end

  # :ditto
  @[AlwaysInline]
  def read_txt_file(txt_path : String)
    File.read(txt_path).split("\n\n")
  end

  # save chap text file with body parts provided
  @[AlwaysInline]
  def save_txt_file(seed : WnSeed, chap : WnChap) : Nil
    save_txt_file(gen_txt_path(seed, chap), chap.body)
  end

  # :ditto:
  @[AlwaysInline]
  def save_txt_file(txt_path : String, body_parts : Array(String)) : Nil
    Dir.mkdir_p(File.dirname(txt_path))
    File.write(txt_path, body_parts.join("\n\n"))
  end

  #############

  ZIP_DIR = "var/chaps/texts"

  # generate zip path
  @[AlwaysInline]
  def gen_zip_path(seed : WnSeed, chap : WnChap)
    sname = seed.sname
    sname = sname[1..] if seed.bg_seed? # remove prefix for background seeds
    gen_zip_path(sname, seed.s_bid, chap.ch_no!)
  end

  # :ditto:
  @[AlwaysInline]
  def gen_zip_path(sname : String, s_bid : Int32, ch_no : Int32)
    "#{ZIP_DIR}/#{sname}/#{s_bid}/#{(ch_no &- 1) // 128}.zip"
  end

  # read text from zip file
  @[AlwaysInline]
  def read_txt_from_zip(seed : WnSeed, chap : WnChap)
    zip_path = gen_zip_path(seed.sname, seed.s_bid, chap.ch_no)
    read_txt_from_zip(zip_path, chap.s_cid, chap.p_len)
  end

  # :ditto
  def read_txt_from_zip(zip_path : String, s_cid : Int32, p_len = 0) : Array(String)
    unless File.file?(zip_path)
      return [""] unless File.file?(zip_path.sub(".zip", ".tab"))
      return [""] unless pull_zip_from_r2!(zip_path)
    end

    Compress::Zip::File.open(zip_path) do |zip|
      # for new entry, all text parts are combined to a single file
      if new_entry = zip["#{s_cid}.txt"]?
        return new_entry.open(&.gets_to_end).split("\n\n")
      end

      # fall back to old storing method

      parts = [] of String

      p_len = 100 if p_len == 0
      p_len.times do |_part|
        break unless entry = zip["#{s_cid}-#{_part}.txt"]?
        ptext = entry.open(&.gets_to_end)

        if _part == 0
          title, ptext = ptext.split('\n', 2)
          parts << title << ptext
        else
          parts << ptext.sub(/^.+?\n/, "") # remove chapter title
        end
      end

      parts
    rescue
      [""]
    end
  end

  # download zip from cloudflare r2 object storage
  private def pull_zip_from_r2!(file : String)
    path = file.sub(ZIP_DIR, "") # object path
    HTTP::Client.get("https://cr2.chivi.app/texts/#{path}") do |res|
      return false if res.status_code >= 300
      File.write(file, res.body_io)
      true
    end
  end
end
