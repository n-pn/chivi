require "colorize"

INP = "_db/prime/chdata/texts/.skip"

def archive(seed : String)
  seed_path = File.join(INP, seed)
  unless File.exists?(seed_path)
    return puts "#{seed} not found!".colorize.red
  end

  book_bids = Dir.children(seed_path)
  book_bids.each_with_index do |bid, idx|
    zip_name = File.join(seed_path, "#{bid}.zip")
    book_seed = File.join(seed_path, bid)

    puts "- <#{idx + 1}/#{book_bids.size}> [#{seed}/#{bid}.zip]".colorize.blue
    puts `zip -rjm "#{zip_name}" #{File.join(book_seed, "*.txt")}`
  rescue err
    puts err.colorize.red
    gets
  end
end

seeds = ARGV.empty? ? Dir.children(INP) : ARGV
seeds.each do |seed|
  spaw { archive(seed) }
end
