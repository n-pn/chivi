# # pronouns

ProUnkn = 200

# 人称代词 - personal pronoun - đại từ nhân xưng
ProPer1 = 201 # first person
ProPer2 = 202 # second person
ProPer3 = 203 # third person
ProPerX = 204 # other personal pronoun

# special personal pronouns
ProZiji = 206 # "自己"

# 指示代词 - demonstrative pronoun - đại từ chỉ thị
ProDem = 210 # generic

# special cases
ProZhe = 215 # "这"
ProNa1 = 216 # "那"
ProJi  = 217 # "几"

ProNa2 = 229 # "哪"
# 疑问代词 - interrogative pronoun
ProInt = 230 # generic

# # numbers
# numeral
Ordinal = 240 # 序数词 ordinal number
Numeric = 241 # 基数词 generic cardinal number

Ndigit1 = 242 # all digits
Ndigit2 = 243 # digits with '-', '/', '~' between

Nhanzi0 = 244 # all chinese number, unknown state
Nhanzi1 = 245 # chinese number, can convert to number
Nhanzi2 = 246 # chinese number, approximate

NumYi1 = 247 # "一"
NumHan = 249 # "半"

# quantifier
Qtnoun = 260 # quantifier for noun phrase
Qtmass = 261
Qtwght = 263 # weight
Qtdist = 264 # distance
Qtcash = 265 # currency

Qttime = 269 # verb complement, can be subject
Qtverb = 270 # verb complement

# QtGe4 = 266 # "个"
# QtBa3 = 267 # "把"
# QtDui = 268 # "对"

# QtLiang = 269 # "两"

# QtDian = 270 # "点"
# QtFen1 = 271 # "分"
# QtMiao = 272 # "秒", "秒钟"

# QtNian = 275 # "年"
# QtYue4 = 276 # "月"

# QtRi4 = 277 # "日"
# QtHao = 278 # "号"

# number + quantifier
Nqnoun = 280
Nqmass = 281

Nqwght = 283
Nqdist = 284
Nqcash = 285

Nqtime = 289
Nqverb = 290
