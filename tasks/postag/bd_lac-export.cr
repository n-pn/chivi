require "colorize"
require "tabkv"

require "../../src/_init/postag_init"
require "../../src/cvmtl/mt_core"

module CV
  extend self

  SUM = "_db/vpinit/bd_lac/sum"
  OUT = "_db/vpinit/bd_lac/out"

  def add_book(file : String, books)
    PostagInit.new(file).data.each do |term, counts|
      books.update_count(term, counts.first_key, 1)
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

    top25 = PostagInit.new("#{OUT}/t25-books.tsv", reset: true)
    top50 = PostagInit.new("#{OUT}/t50-books.tsv", reset: true)

    input.data.each do |term, counts|
      count = counts.values.sum &+ (BONUS[term]? || 0)

      next if count < 25
      top25.data[term] = counts
      top50.data[term] = counts if count >= 50
    end

    top25.save!
    top50.save!
  end

  extract_top
end
