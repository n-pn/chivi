# punctuation

Empty = 0 # ""
Space = 1 # " "

Period = 4 # "."
Exclpm = 5 # "!"
Quespm = 6 # "?"

###########

DbQuote = 8 # "\""
SgQuote = 9 # "'"

QuoteSt1 = 10 # "“"
QuoteSt2 = 11 # "‘"

TitleSt1 = 12 # "⟨"
TitleSt2 = 13 # "<"
TitleSt3 = 14 # "‹"

ParenSt1 = 15 # "("

BrackSt1 = 17 # "["
BrackSt2 = 18 # "{"

QuoteCl1 = 20 # "”"
QuoteCl2 = 21 # "’"

TitleCl1 = 22 # "⟩"
TitleCl2 = 23 # ">"
TitleCl3 = 24 # "›"

ParenCl1 = 25 # ")"

BrackCl1 = 27 # "]"
BrackCl2 = 28 # "}"

##########

Colon = 31 # ":"
Smcln = 32 # ";"

Comma = 33 # ","
Cenum = 34 # "､"

Dash1 = 35 # "–"
Dash2 = 36 # "—"

Ellip1 = 37 # "…"
Ellip2 = 38 # "……"

Tilde = 39 # "~"

Middot = 41 # "·"
Atsign = 42 # "@"

Pcmark = 43 # "‰", "%"
Qtmark = 44 # "￥", "$", "￡", "°", "℃"

PlMark = 47 # "+"
MnMark = 48 # "-"

Punct = 49 # other punctuations

# idioms, locutions

LitBlank = 60 # unknown/untagged phrases
LitIdiom = 61 # chinese idiom that have multi classes
LitQuote = 62 # citations, quotes
LitTrans = 63 # partial translations

# string literals

StrLink  = 81 # hyper link (can act as object)
StrMail  = 82 # email string (can act as object)
StrHash  = 83 # hash tag (can act as object)
StrEmoji = 84 # emotions
StrOther = 85 # other raw string
