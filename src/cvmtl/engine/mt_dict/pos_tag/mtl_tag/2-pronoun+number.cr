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
Qtverb = 260 # verb complement
Qttime = 261 # verb complement, can be subject

Qtnoun = 265 # quantifier for noun phrase
Qtmass = 266
Qtwght = 267 # weight
Qtdist = 268 # distance
Qtcash = 269 # currency

QtGe4 = 270 # "个"
QtBa3 = 271 # "把"
QtDui = 272 # "对"

QtLiang = 273 # "两"

# QtDian = 270 # "点"
# QtFen1 = 271 # "分"
# QtMiao = 272 # "秒", "秒钟"

# QtNian = 275 # "年"
# QtYue4 = 276 # "月"

# QtRi4 = 277 # "日"
# QtHao = 278 # "号"

# number + quantifier
Nqverb = 280 # verb complement
Nqtime = 281 # verb complement, can be subject

Nqnoun = 285 # quantifier for noun phrase
Nqmass = 286
Nqwght = 287 # weight
Nqdist = 288 # distance
Nqcash = 289 # currency
