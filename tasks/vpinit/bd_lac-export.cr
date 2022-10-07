require "colorize"
require "tabkv"

require "../../src/_init/postag_init"
require "../../src/mtlv1/mt_core"
require "../../src/mtlv1/tl_name"

module CV
  extend self

  SUM = "_db/vpinit/bd_lac/sum"
  OUT = "_db/vpinit/bd_lac/out"

  def add_book(file : String, target)
    PostagInit.new(file).data.each do |term, counts|
      target.update_count(term, counts.first_key, 1)
    end
  end

  def combine_raw
    books = PostagInit.new("#{OUT}/raw-books.tsv", reset: true)
    # ptags = PostagInit.new("#{OUT}/all-ptags.tsv", reset: true)

    Dir.glob("#{SUM}/*.tsv").each do |file|
      add_book(file, books)
    end

    books.save!
  end

  # combine_raw

  BONUS = Tabkv(Int32).new("_db/vpinit/term-bonus.tsv")

  def should_keep?(term : String)
    return true if BONUS[term]?

    term =~ /^[\p{Han}a-zA-Z0-9-_.· ○]+$/
  end

  def reduce_raw
    input = PostagInit.new("#{OUT}/raw-books.tsv")
    keep = PostagInit.new("#{OUT}/all-books.tsv", reset: true)
    skip = PostagInit.new("#{OUT}/del-books.tsv", reset: true)
    punc = PostagInit.new("#{OUT}/puncts.tsv", reset: true)

    input.data.each do |term, counts|
      if should_keep?(term)
        keep.data[term] = counts
      elsif term.size == 1 && counts.first_key == "w"
        punc.data[term] = counts
      else
        skip.data[term] = counts
      end
    end

    keep.save!(sort: true)
    skip.save!(sort: true)
    punc.save!(sort: true)
  end

  # reduce_raw

  def extract_top
    input = PostagInit.new("#{OUT}/all-books.tsv")

    top25 = PostagInit.new("#{OUT}/top25-raw.tsv", reset: true)
    top50 = PostagInit.new("#{OUT}/top50-raw.tsv", reset: true)

    input.data.each do |term, counts|
      count = counts.values.sum &+ (BONUS[term]? || 0)

      next if count < 25
      top25.data[term] = counts
      top50.data[term] = counts if count >= 50
    end

    top25.save!
    top50.save!
  end

  # extract_top

  def export_top25
    picked = File.read_lines("#{OUT}/top25-raw.tsv").map(&.split('\t', 2).first).to_set

    target = PostagInit.new("#{OUT}/top25-all.tsv", reset: true)

    Dir.glob("#{SUM}/*.tsv").each do |file|
      reduce_value = File.read_lines(file.sub(".tsv", ".log")).size
      reduce_value = reduce_value // 10 &+ 1

      PostagInit.new(file).data.each do |term, counts|
        next unless picked.includes?(term)

        minimal = counts.first_value // 10
        minimal = 10 if minimal > 10

        counts.each do |tag, count|
          next if count < minimal
          target.update_count(term, tag, count // reduce_value + 1)
        end
      end
    rescue err
      puts err
    end

    target.save!(sort: true)
  end

  def split_by_tag_types(inp_name : String, out_dir : String)
    input = PostagInit.new("#{OUT}/#{inp_name}.tsv")

    ondict = PostagInit.new("#{OUT}/#{out_dir}/ondict.tsv", reset: true)
    unseen = PostagInit.new("#{OUT}/#{out_dir}/unseen.tsv", reset: true)

    ondict_names = PostagInit.new("#{OUT}/#{out_dir}/ondict-names.tsv", reset: true)
    ondict_words = PostagInit.new("#{OUT}/#{out_dir}/ondict-words.tsv", reset: true)

    unseen_names = PostagInit.new("#{OUT}/#{out_dir}/unseen-names.tsv", reset: true)
    unseen_words = PostagInit.new("#{OUT}/#{out_dir}/unseen-words.tsv", reset: true)

    input.data.each do |key, counts|
      is_names = counts.first_key.in?("nr", "nn", "nx", "nz")

      if BONUS[key]?
        ondict.data[key] = counts

        if is_names
          ondict_names.data[key] = counts
        else
          ondict_words.data[key] = counts
        end
      else
        unseen.data[key] = counts

        if is_names
          unseen_names.data[key] = counts
        else
          unseen_words.data[key] = counts
        end
      end
    end

    ondict.save!(sort: true)
    unseen.save!(sort: true)

    ondict_names.save!(sort: true)
    ondict_words.save!(sort: true)

    unseen_names.save!(sort: true)
    unseen_words.save!(sort: true)
  end

  # split_by_tag_types("top25-all", "top25")

  def gen_limits(chap_checked)
    # min_count: minimal occurency of a phrase to be considered keeping
    # base on number of chapters analyzed
    # note that almost all chapters size the same (around 3k chars)
    # so using chap count is good enough

    if chap_checked < 100
      min_count = 10 # characters mentioned less than 10 times are not worth considering
    elsif chap_checked > 250
      min_count = 25 # since there are series that have 3000+ chapters, we need upper limit
    else
      min_count = chap_checked // 10
    end

    # fail_safe:
    # Usually we will skip including the terms already existed in `regular` dictionary
    # But entries in `regular` dictionary is unreliable since the dict applied to
    # all books, sometime the terms will be changed by users for reasons.
    # By introducting a fail_safe limit, we will still keep the names in book dictionary
    # so they won't be affected by global state
    # this only applies to named entries (nr/nn/nx/nz tags)

    if chap_checked < 100
      # even the chapters checked is under 100, we still keep the minimal value to 100
      # so the dict is not filled with too many regular terms
      fail_safe = 100
    elsif chap_checked < 500
      # names that popular enough that the occurency of them at least equal to checked chapters
      fail_safe = chap_checked
    else
      fail_safe = 500 # 500 times is enough to keep it in book dict
    end

    {min_count, fail_safe}
  end

  def get_first_tag(key : String, counts : Hash(String, Int32)) : String
    count_nn = (counts["ns"]? || 0) &+ (counts["nt"]? || 0)
    first_tag = count_nn > counts.first_value ? "nn" : counts.first_key

    case first_tag
    when "nr" then return fix_nr_tag(key, counts)
    when "nz" then return fix_nz_tag(key, counts)
    when "ns" then return fix_ns_tag(key, counts)
    when "nt" then return fix_nt_tag(key, counts)
    when "nx"
      return "nz" if key.ends_with?("号")
    end

    first_tag
  end

  def fix_nr_tag(key : String, counts)
    case key
    when .=~ /军|族|宗|氏$/   then "nt"
    when .ends_with?("道") then "~sv"
    when .ends_with?("人")
      TlName.is_human?(key) ? "nr" : "nz"
    else
      if counts["nt"]?.try(&.> 10)
        return TlName.is_cap_affil?(key) ? "nt" : "nz"
      end

      return "nr" unless counts["ns"]?.try(&.> 10)
      TlName.is_cap_affil?(key) ? "ns" : "nr"
    end
  end

  def fix_ns_tag(key : String, counts)
    case key
    when .ends_with?("上") then "s"
    when .ends_with?("内") then "s"
    else
      return "ns" unless counts["nr"]?.try(&.> 10)
      TlName.is_human?(key) ? "nr" : "ns"
    end
  end

  def fix_nt_tag(key : String, counts)
    return "nt" unless counts["nr"]?.try(&.> 10)
    TlName.is_human?(key) ? "nr" : "nt"
  end

  def fix_nz_tag(key : String, counts)
    case key
    when .ends_with?("部族") then "nt"
    when .ends_with?("世界") then "ns"
    else
      if counts["nr"]?.try(&.> 10)
        return TlName.is_human?(key) ? "nr" : "nz"
      end

      if counts["nt"]?.try(&.> 5)
        return TlName.is_cap_affil?(key) ? "nt" : "nz"
      end

      return "nz" unless counts["ns"]?.try(&.> 5)
      TlName.is_cap_affil?(key) ? "ns" : "nz"
    end
  end

  def export_books
    global = PostagInit.new("#{OUT}/top50-raw.tsv")

    Dir.glob("#{SUM}/*.tsv").each do |file|
      chap_checked = File.read_lines(file.sub(".tsv", ".log")).size
      min_count, fail_safe = gen_limits(chap_checked)

      bslug = File.basename(file, ".tsv")

      bdict_names = PostagInit.new("#{OUT}/books/#{bslug}-names.tsv", reset: true)
      bdict_other = PostagInit.new("#{OUT}/books/#{bslug}-other.tsv", reset: true)

      PostagInit.new(file).data.each do |word, counts|
        next if word.ends_with?("的")

        count_sum = counts.each_value.sum

        # reject if this entry does not appear frequenly enough
        next if count_sum < min_count
        first_tag = get_first_tag(word, counts)

        next if first_tag.in?("w", "xc", "m")
        is_names = first_tag.in?("nr", "nn", "nt", "ns", "nx", "nz")

        if global_counts = global.data[word]?
          if global_counts.first_key == first_tag
            # keep the names if it appear frequently enough
            next unless first_tag == "nr" && count_sum >= fail_safe
            # only if the term not exists in common dicts
            next if BONUS[word]?
          end
        end

        if is_names
          bdict_names.data[word] = counts
        else
          bdict_other.data[word] = counts
        end
      end

      bdict_names.save!(sort: true)
      bdict_other.save!(sort: true)
    rescue err
      puts err
    end
  end

  def combine_books_names_to_check_translation
    output = Set(String).new
    Dir.glob("#{OUT}/books/*-names.tsv").each do |file|
      lines = File.read_lines(file)
      lines.each { |line| output << line.split('\t', 2).first }
    end

    File.write("#{OUT}/book-names.txt", output.join("\n"))
  end

  export_books
  # combine_books_names_to_check_translation
end
