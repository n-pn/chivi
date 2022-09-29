# idioms, locutions

LitBlank = 0 # unknown/untagged phrases
LitIdiom = 1 # chinese idiom that have multi classes
LitQuote = 2 # citations, quotes
LitTrans = 3 # partial translations

# string literals

StrLink  = 21 # hyper link (can act as object)
StrMail  = 22 # email string (can act as object)
StrHash  = 23 # hash tag (can act as object)
StrEmoji = 24 # emotions
StrOther = 25 # other raw string

# phrases

VerbPhrase = 51 # noun + verb (can act as determiner)
AdjtPhrase = 52 # noun + adjt (can act as determiner)
DedePhrase = 53 # demonstrate determiner
PodePhrase = 54 # possessive determiner

AdavPhrase = 71 # phrase that can act as manner adverb
PrepPhrase = 72 # prepos + noun phrase
