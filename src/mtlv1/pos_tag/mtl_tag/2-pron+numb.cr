# # pronouns

ProUnkn = 200

# 人称代词 - personal pronoun - đại từ nhân xưng
ProPer0 = 210 # generic
ProPer1 = 211 # first person
ProPer2 = 212 # second person
ProPer3 = 213 # third person

# special personal pronouns
ProZiji = 216 # "自己"

# 指示代词 - demonstrative pronoun - đại từ chỉ thị
ProDem0 = 220 # generic
ProDem1 = 221 # Det+M phrase

# special cases
ProZhe = 235 # "这"
ProNa1 = 236 # "那"
ProJi  = 237 # "几"

# 疑问代词 - interrogative pronoun
ProInt0 = 240 # generic
ProInt1 = 241 # can split

ProNa2 = 245 # "哪"

# # numbers
# numeral
Number = 250 # 基数词 generic cardinal number
Numord = 251 # 序数词 generic ordinal number

Ndigit1 = 251 # all digits
Ndigit2 = 252 # digits with '-', '/', '~' between

Numhan0 = 254 # all chinese number, unknown state
Numhan1 = 255 # chinese number, can convert to number
Numhan2 = 256 # chinese number, approximate

NumHan = 257 # "半"
NumYi1 = 258 # "一"

# quantifier
Qtnoun  = 260 # quantifier for noun phrase
Qttime1 = 261 # verb complement, can be subject
Qttime2 = 262 # verb complement or adverb, can be subject

Qtverb1 = 263 # verb complement
Qtverb2 = 264 # verb complement or adverb

Qtredup = 265 # redupication

QtGe4 = 266 # "个"
QtBa3 = 267 # "把"
QtDui = 268 # "对"

QtLiang = 269 # "两"

QtDian = 270 # "点"
QtFen1 = 271 # "分"
QtMiao = 272 # "秒", "秒钟"

QtNian = 275 # "年"
QtYue4 = 276 # "月"

QtRi4 = 277 # "日"
QtHao = 278 # "号"

# number + quantifier
Nqnoun = 280

Nqtime1 = 281
Nqtime2 = 282

Nqverb1 = 283
Nqverb2 = 284

Nqredup = 285

NqtimeX = 286 # can be timeword
NqverbX = 287 # can be verbal
