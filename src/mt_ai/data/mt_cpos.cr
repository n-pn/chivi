#   # EXTRA TAGS:
#   # N: all nouns
#   # V: all verbs/adjts
#   # C: all content words
#   # F: all function words

#   SUPERSETS = {
#     "VV" => {"V", "C"},
#     "VA" => {"V", "C"},
#     "NN" => {"N", "C"},
#     "NT" => {"N", "C"},
#   }

class MT::MtCpos
  POS = Hash(String, Int32).new { |h, k| h[k] = h.size }

  POS["_"] = 0

  NN = POS["NN"]
  NP = POS["NP"]
end
