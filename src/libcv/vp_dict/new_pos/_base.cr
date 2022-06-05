module CV::POS
  # from: https://resources.allsetlearning.com/chinese/grammar/Part_of_speech

  # # Function Words (虚词)
  # # The character 虚 refers to that which is "false" or "not real," or "empty."
  # # In this case, the words are "empty" in that they don't do anything by themselves.
  # # They serve important grammatical functions by making clear relationships between
  # # words, logical connections, or modifications of meaning. Hence, the Chinese word
  # # 虚词 is a bit difficult to translate, and is listed in the ABC Dictionary as all
  # # of the following: "function word/form word/cenematic word/empty word/syncategorematic
  # # word; functive; particle."
  # # Function words are the "grammar words" of modern Chinese. They're the 了, the 着,
  # # the 于, the 向, the 和, and the 却. These are the ones that tend to give learners
  # # are a hard time. The good news is that it's not random words that are designated
  # # as function words; it's whole categories of words, whole parts of speech. The parts
  # # of speech classified as function words are: prepositions, conjunctions, and particles.
  # module Function; end

  # # real words
  # module Content; end

  # module Puntuation; end

  # module Popens
  #   # denote sentence start
  # end

  # module Pstops
  #   # denote sentence stop
  # end

  # module Objects
  #   # can act as object of verbs/preposes
  # end

  # module Nominal
  #   # all kind of nouns
  # end

  # module NProper
  #   # human name, location name, organization, book titles, other proper nouns
  # end

  # module Attribute
  #   # special kind of nouns that act as attrribute instead of possessive
  #   # including:
  #   # - location/organization
  #   # - locative/position
  #   # - temporal
  # end

  # module Placement
  #   # - location/organization
  #   # - position
  # end

  # module Humankind
  #   # human names, human title or personal pronoun
  # end

  # module Temporal
  # end

  # ##########

  # module Verbal
  #   # all kind of verbs
  # end

  # module Adjective
  #   # all kind of adjective
  # end

  # module Modifier
  #   # modifier adjective
  # end

  # module Adverbial
  #   # all kind of adverbs
  # end

  # ########

  # module Numeral
  # end

  # #####

  # module Mixed
  # end

  # module Special
  #   #
  # end

  module Objects; end

  module Special; end

  module Mankind; end

  module Attribs; end

  ############

  struct Generic
    # property key : String
    # property val : String
  end

  struct Punctuation < Generic; end # punctuation

  struct ContentWord < Generic; end # content words

  struct FunctionWord < Generic; end # function words

  struct Unknown < ContentWord; end

  struct Polytag < ContentWord; end
end
