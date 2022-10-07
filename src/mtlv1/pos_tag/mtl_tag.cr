enum CV::MtlTag
  {% begin %}
    {% files = {
         "0-lit+str+punct",
         "1-name+noun",
         "2-pronoun+number",
         "3-verb+adjective",
         "4-prepos+particle",
         "5-adverb+conjunct",
         "6-phrase+catena",
         "7-sound+morp",
         "8-polysemy",
         "9-uniqword",
       } %}
    {% for file in files %}
      {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.cr").split("\n") %}
      {% for line in lines %}
      {{ line.id }}
      {% end %}
    {% end %}
  {% end %}

  # 0 lit + str + punct

  def puncts?
    value < 50
  end

  def pfinal?
    value >= 4 && value <= 6
  end

  def pstart?
    value >= 8 && value < 20
  end

  def pclose?
    value >= 20 && value < 30
  end

  def pgroup?
    value >= 8 && value < 30
  end

  def dashes?
    value == Dash1.value || value == Dash2.value
  end

  def brack_sts?
    value == BrackSt1.value || value == BrackSt2.value
  end

  def title_sts?
    value >= TitleSt1.value && value <= TitleSt3.value
  end

  def title_cls?
    value >= TitleCl1.value && value <= TitleCl3.value
  end

  def ellipsis?
    value == Ellip1.value || value == Ellip2.value
  end

  ####

  def literal?
    value >= 60 && value < 90
  end

  def strings?
    value >= 80 && value < 90
  end

  # 1 name + noun

  def names?
    value >= 100 && value < 120
  end

  def affil?
    value >= 105 && value < 110
  end

  def nouns?
    value >= 120 && value < 155
  end

  def nobjs?
    value >= 140 && value <= 150
  end

  def nominal?
    value >= 100 && value < 200
  end

  def honorific?
    value >= 120 && value < 125
  end

  def position?
    value >= 150 && value < 180
  end

  def locative?
    value >= 160 && value < 180
  end

  def timeword?
    value >= 180 && value < 200
  end

  # pronouns

  def pronouns?
    value >= 200 && value < 240
  end

  def pro_pers?
    value >= 201 && value < 210
  end

  def pro_dems?
    value >= 210 && value < 230
  end

  def pro_ints?
    value >= 229 && value < 240
  end

  def pro_split?
    value >= 214 && value < 229
  end

  # numbers

  def numeral?
    value >= 240 && value < 300
  end

  def numbers?
    value >= 240 && value < 260
  end

  def ndigits?
    value >= 242 && value <= 243
  end

  def nhanzis?
    value >= 244 && value <= 246
  end

  def quantis?
    value >= 260 && value < 280
  end

  def nquants?
    value >= 280 && value < 300
  end

  # verbal

  def vobjs?
    value >= 300 && value < 305
  end

  def verbs?
    value >= 300 && value < 340
  end

  def verbal?
    value >= 300 && value < 350
  end

  def special_verb?
    value >= 330 && value < 350
  end

  def verb_no_obj?
    value < 310 && value >= 300
  end

  def verb_take_obj?
    value >= 309 && value < 350
  end

  def verb_take_res_cmpl?
    value >= 308 && value <= 314
  end

  def verb_take_verb?
    value >= 316 && value < 330
  end

  def vmodals?
    value >= 318 && value < 330
  end

  # adjts?

  def adjts?
    value >= 350 && value < 400
  end

  def modis?
    value >= 370 && value < 400
  end

  def content?
    value < 400
  end

  # 4 prepos + particle

  def preposes?
    value >= 400 && value < 450
  end

  # particle

  def particles?
    value >= 450 && value < 500
  end

  def aspect?
    value >= 452 && value <= 455
  end

  def pt_ects?
    value >= 480 && value < 490
  end

  def pt_cmps?
    value >= 490 && value < 500
  end

  # adverb

  def adverbs?
    value >= 500 && value < 560
  end

  def nega_advs?
    value >= 510 && value < 520
  end

  def time_advs?
    value >= 520 && value < 525
  end

  def scope_advs?
    (value > 520 && value < 530) || value == AdvDu1
  end

  def mood_advs?
    value > 225 && value < 535
  end

  def freque_advs?
    value >= 535 && value < 545
  end

  def correl_advs?
    value > 535 && value < 550
  end

  def manner_advs?
    value >= 550 && value < 560
  end

  def serial_advs? # linking verbs
    value.in?(AdvJiu3, AdvZai4, AdvCai)
  end

  ###

  def conjuncts?
    value >= 559 && value < 600
  end

  def concoords?
    value >= 570 && value < 600
  end

  # phrases

  def phrases?
    value >= 600 && value < 680
  end

  def morpheme?
    value >= 730 && value < 800
  end

  def suffixes?
    value >= 730 && value < 750
  end

  # words that have multi meaning/part-of-speech
  def polysemy?
    value >= 800 && value < 900
  end

  # special words that need to be check before build semantic tree
  def uniqword?
    value >= 900 && value < 1000
  end

  # words need to be fix (including uniqword and polysemy)
  def nebulous?
    value >= 800 && value < 1000
  end

  # words that can link two content words

  def bond_words?
    value >= 1000 && value < 1050
  end

  def bond_names?
    value >= 1000 && value < 1010
  end

  def bond_nouns?
    value >= 1010 && value < 1020
  end

  def bond_adts?
    value >= 1020 && value < 1030
  end

  def bond_verbs?
    value >= 1030 && value < 1040
  end
end
