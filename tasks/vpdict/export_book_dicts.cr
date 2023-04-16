# require "colorize"
# require "tabkv"

# require "../../src/_init/postag_init"
# require "../../src/mt_v2/tl_name"
# require "../shared/bootstrap"

# EPOCH = CV::VpTerm.mtime(Time.local(2021, 10, 1))

# def similar_tag?(attr : String, ptag : String)
#   return true if attr == ptag || attr.empty?
#   return true if attr == "Na" && ptag.in?("nt", "ns")
#   return true if attr == "nz" && ptag == "nx"

#   false
# end

# def extract_book(file : String)
#   bslug = File.basename(file).sub("-names.tsv", "")
#   return unless bhash = CV::Wninfo.load!(bslug).try(&.bhash)

#   vdict = CV::VpDict.load_novel(bhash, mode: :none)
#   vdict.load!(vdict.flog) if File.exists?(vdict.flog)
#   tl_name = CV::TlName.new(vdict)

#   input = CV::PostagInit.new(file).data
#   input = input.to_a.sort_by!(&.[0].size)

#   input.each do |key, counts|
#     count_nn = counts["ns"] + counts["nt"]
#     main_tag = count_nn > counts.first_value ? "nn" : counts.first_key

#     min_count = counts.first_value // 8

#     top_tags = counts.reject! { |_, c| c < min_count }.keys

#     if old_term = vdict.find(key)
#       old_val = old_term.val.first

#       if similar_tag?(old_term.attr, main_tag)
#         next if old_term.attr == main_tag
#       else
#         if old_term.attr.in?(top_tags)
#           color = :green
#         elsif old_val == old_val.downcase
#           main_tag = old_term == "n" ? "n" : "nz"
#           color = :blue
#         elsif old_term.mtime >= EPOCH
#           color = :cyan
#         else
#           color = :light_red
#         end

#         puts "#{key}\t#{old_term.val.join('/')}\t#{old_term.uname}\t#{Time.unix(old_term.utime)}".colorize(color)
#         puts "tags: #{old_term.attr} => #{main_tag} [#{counts}".colorize(color)

#         next if color.in?(:green, :cyan)
#       end

#       vals = old_term.val

#       uname = old_term.uname
#       mtime = old_term.mtime + 2
#     else
#       vals = tl_name.tl_by_ptag(key, main_tag).first(1)
#       uname = "[cv]"
#       mtime = 0
#     end

#     vdict.set(CV::VpTerm.new(key, vals, main_tag, mtime: mtime, uname: uname))
#   end

#   vdict.save!
# end

# INP = "_db/vpinit/bd_lac/out/books"
# OUT = "var/vpdicts/v1/novel"

# files = Dir.glob("#{INP}/*-names.tsv")
# files.each { |file| extract_book(file) }
