# # pronouns

ProUnkn = 200

# 人称代词 - personal pronoun - đại từ nhân xưng
ProPer1 = 201 # first person
ProPer2 = 202 # second person
ProPer3 = 203 # third person
ProPerX = 204 # other personal pronoun

# special personal pronouns
ProZiji = 206 # "自己"
ProQu2  = 207 # "其"

# 指示代词 - demonstrative pronoun - đại từ chỉ thị
ProDem = 210 # generic

# special cases
ProZhe = 214 # "这"
ProNa1 = 215 # "那"
ProMei = 216 # "每"

ProJi  = 228 # "几"
ProNa2 = 229 # "哪"
# 疑问代词 - interrogative pronoun
ProInt  = 230 # generic
ProShei = 231

# # numbers
# numeral
Ordinal = 240 # 序数词 ordinal number
Numeric = 241 # 基数词 generic cardinal number

Ndigit0 = 242 # all digits
Ndigit1 = 243 # digits with decimal point
Ndigit2 = 244 # fractal number
Ndigit3 = 245 # approximate numbers (has `-`, `~` between)

Nhanzi0 = 247 # all chinese number, unknown state
Nhanzi1 = 248 # chinese number, can convert to number
Nhanzi2 = 249 # chinese number, approximate

Nmixed0 = 250 # mixed digits with hanzi units
Nmixed1 = 251 # mixed approximate digits with hanzi units
# Nmixed2 = 252 # to be determined
# Nmixed3 = 253 # to be determined

NumYi1   = 255 # "一"
NumLiang = 256 # "两"
NumHan   = 257 # "半"

# quantifier
Qtnoun = 260 # quantifier for noun phrase
Qtmass = 261
Qtwght = 263 # weight
Qtdist = 264 # distance
Qtcash = 265 # currency

Qttime = 269 # verb complement, can be subject
Qtverb = 270 # verb complement

QtGe4 = 266 # "个"
QtBa3 = 267 # "把"
QtDui = 268 # "对"

QtLiang = 269 # "两"

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
