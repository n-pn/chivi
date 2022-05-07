require "./_postag"

INP = "_db/vpinit/corpus"

merger = CV::Merger.new("#{INP}/pfrtag.tsv")

merger.add_tagsum!("#{INP}/pfrtag/pfr14.tsv")
merger.add_tagsum!("#{INP}/pfrtag/pfr98.tsv")

merger.save!
