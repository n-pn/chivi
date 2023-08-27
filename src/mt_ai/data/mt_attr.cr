require "../../_util/char_util"

@[Flags]
enum AI::MtOpts
  NONE # ignore node content
  NCAP # do not capitalize

  HEAD # put this in head of a grammar structure
  TAIL # put this in tail of a grammar structure

  CAPA # capitalize the word after this
  CAPR # capitalize the word after this instead capitalize this word

  NWSA # do not add whitespace after this word
  NWSB # do not add whitespace before this word
  NWSR # do not add whitespace after this word if previous word do not need space after

end
