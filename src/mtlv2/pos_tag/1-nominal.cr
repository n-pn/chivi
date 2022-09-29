# nominal

# proper nouns
Human0 = 100 # generic human name
Human1 = 101 # nick name/handle name

Human2 = 102 # chinese full name/chinese first name
Human3 = 103 # chinese family name
Human4 = 104 # special chinese family name(has other roles)

Human5 = 106 # foreign human name
Human6 = 107 # japanese human name

Affil0 = 110 # place name or organization
Affil1 = 111 # place name
Affil2 = 112 # organization

Affil3 = 113 # foreign affil
Affil4 = 114 # foreign place
Affil5 = 115 # foreign institute

# other proper nouns
XOther = 120 # other proper noun
XTitle = 121 # book title, work name
XBrand = 122 # brand name
XSkill = 123 # skill name

# honoric
Nhonor0 = 130 # right honorific
Nhonor1 = 131 # right honorific, no space padding
Nhonor2 = 132 # left honorific
Nhonor3 = 133 # left honorific, no space padding

# human related noun
Nkinsh = 135 # kinship, family member
Noccup = 136 # occupational

Nncall = 137 # name calling
Nhuman = 138 # generic human word

# attribute
Nattr0 = 140 # generic attribute
Nattr1 = 141 # color names
Nattr2 = 142 # clothing
Nattr3 = 143 # characteristic (hair, nose, skin...)

# generic noun
Nbase = 150 # generic noun
Nform = 151 # noun phrase

# abstract
Nabst0 = 155 # astract concept
Nabst1 = 156 # can be concrete

# animate noun
Nanim0 = 160 # animate noun
Nanim1 = 161 # animals
Nanim2 = 162 # plants

# inanimate noun
Ninan0 = 170 # generic
Ninan1 = 171 # weapon
# TODO: add more types

# placement
Nplace = 180 # generic place
Npsuff = 182 # combine with prev noun to place

Nposit = 184 # place + locat

# locative
Locat0 = 186 # can act as place
Locat1 = 187 # can not act as place
Locat2 = 188 # special locative words

# temporal
Tword = 190 # unsorted timeword
Tform = 191 # temporal expression
Tspan = 192 # time span, duration
Tmark = 193 # can mark succ term as time

Tdate  = 195 # date
Ttime  = 196 # time
TdateX = 197 # date or mquant
TtimeX = 198 # time or mquant
