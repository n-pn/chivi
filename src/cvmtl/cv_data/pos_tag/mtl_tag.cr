# enum MT::MtlTag : UInt32
#   Empty = 0

#   {% begin %}
#     {% files = {
#          "00-grammar",
#          "01-literal", "02-nominal", "03-pronoun", "04-numeral",
#          "05-verbal", "06-adjective", "07-adverb", "08-conjunct",
#          "09-prepos", "10-particle", "11-others", "12-puncts",
#        } %}
#     {% for file in files %}
#       {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.tsv").split('\n') %}
#       {% for line in lines.reject { |x| x.empty? || x.starts_with?('#') } %}
#         {{ line.split('\t')[1].id }}
#       {% end %}
#     {% end %}
#   {% end %}

#   def punctuations?
#     self >= Pmark
#   end

#   def final_puncts?
#     self >= Period && self <= Quespm
#   end

#   def start_puncts?
#     self >= DbQuote && self <= ParenSt1
#   end

#   def close_puncts?
#     self >= TitleCl1 && self <= ParenCl1
#   end

#   def group_puncts?
#     self >= DbQuote && self <= ParenCl1
#   end

#   def dashes?
#     self == Dash1 || self == Dash2
#   end

#   def brack_sts?
#     self == BrackSt1 || self == BrackSt2
#   end

#   def title_sts?
#     self >= TitleSt1 && self <= TitleSt3
#   end

#   def title_cls?
#     self >= TitleCl1 && self <= TitleCl3
#   end

#   def ellipsis?
#     self == Ellip1 || self == Ellip2
#   end

#   ####

#   # is untagged words
#   def literal?
#     self >= LitBlank && self <= LitTrans
#   end

#   # is foreign entities
#   def strings?
#     self >= StrLink && self <= StrOther
#   end

#   # 1 name + noun
#   # all kind of nouns
#   def all_nouns?
#     self >= HumanName && self <= Timespan
#   end

#   def name_words?
#     self >= HumanName && self <= OtherName
#   end

#   # is place name or oraganization
#   def space_name?
#     self >= PlaceName && self <= AffilName
#   end

#   def other_names?
#     self >= BrandName && self <= OtherName
#   end

#   # is not proper nouns
#   def common_nouns?
#     self >= Noun && self <= OrgSf
#   end

#   # noun is objects
#   def object_nouns?
#     self >= Nobjt && self <= Plant
#   end

#   # common noun that refer to placement/location
#   def place_words?
#     self >= Place && self < Timeword
#   end

#   # all locative words
#   def locat_words?
#     self >= Locat && self < Timeword
#   end

#   # all time words
#   def all_times?
#     self >= Timeword && self < Timespan
#   end

#   # pronouns

#   # all kind of pronouns
#   def all_prons?
#     self >= Pronoun && self < Ordinal
#   end

#   # personal pronouns
#   def per_prons?
#     self >= PerPron && self < DemPron
#   end

#   # demostrate pronouns
#   def dem_prons?
#     self >= DemPron && self < IntPron
#   end

#   # interrogative pronouns
#   def int_prons?
#     self >= IntPron && self < Ordinal
#   end

#   # pronouns that can be modifiers
#   def mod_prons?
#     self >= PronZhe && self <= PronShei
#   end

#   # numberal

#   # all numbers and quantifiers
#   def numerals?
#     self >= Ordinal && self <= Nqdate
#   end

#   # all kind of numbers
#   def numbers?
#     self >= Ordinal && self <= Numeral
#   end

#   def ndigits?
#     self >= Ndigit0 && self <= Ndigit3
#   end

#   def nhanzis?
#     self >= Nhanzi0 && self <= Nhanzi2
#   end

#   def quantis?
#     self >= QtGe4 && self < Nqverb
#   end

#   def nquants?
#     self >= Nqverb && self < Nqdate
#   end

#   # verbal

#   # all kind of verbs
#   def verbal_words?
#     self >= Vobj && self < Adjt
#   end

#   # verb is not copula shi or existent you
#   def common_verbs?
#     self >= Vobj && self < VYou
#   end

#   # special verbs
#   def marked_verbs?
#     self >= VShang && self <= VShi
#   end

#   # verb no need object
#   def verb_no_obj?
#     self < Verb && self >= Vobj
#   end

#   # word that combined verbs with objects
#   def verb_has_obj?
#     self >= Vobj && self < Vmix
#   end

#   # verb that can consume objects
#   def verb_take_obj?
#     self >= Vinx && self < Adjt
#   end

#   # verb can combine with verb
#   def verb_take_verb?
#     self >= Vpsy && self < VShang
#   end

#   # verb that can combine with result complement
#   def verb_take_res_cmpl?
#     self >= Vint && self <= Vdir
#   end

#   # all kind of modal verbs
#   def modal_verbs?
#     self >= Vmod && self < VShang
#   end

#   # adjts

#   # all adjective kinds
#   def adjt_words?
#     self >= Adjt && self < Adverb
#   end

#   def amod_words?
#     self >= Amod && self < Ades
#   end

#   # adverb

#   def advb_words?
#     self >= Adverb && self <= AdvManner
#   end

#   def nega_advs?
#     self >= AdvNega && self < AdvDegree
#   end

#   def degree_advs?
#     self >= AdvDegree && self < AdvTime
#   end

#   def time_advs?
#     self >= AdvTime && self < AdvScope
#   end

#   def scope_advs?
#     (self > AdvTime && self < AdvMood) || self == AdvDu1
#   end

#   def mood_advs?
#     self > AdvMood && self < AdvFreque
#   end

#   def freque_advs?
#     self >= AdvFreque && self < AdvCorrel
#   end

#   def correl_advs?
#     self > AdvFreque && self < AdvManner
#   end

#   def manner_advs?
#     self >= AdvManner && self < ConjAdvb
#   end

#   def serial_advs? # linking verbs
#     self.in?(AdvJiu3, AdvZai4, AdvCai)
#   end

#   ###

#   def conjuncts?
#     self >= ConjAdvb && self < Prepos
#   end

#   def concoords?
#     self >= Conmixed && self < Prepos
#   end

#   # preposes

#   def preposes?
#     self >= Prepos && self < PtclLe
#   end

#   # particle

#   def particles?
#     self >= PtclLe && self <= PtclBan
#   end

#   def aspect_marker?
#     self >= PtclLe && self <= PtclSuo
#   end

#   def ptcl_deps?
#     self >= PtclDep && self <= PtclDeg
#   end

#   def ptcl_etcs?
#     self >= PtclYunyun && self <= PtclDeng3
#   end

#   def ptcl_cmps?
#     self >= PtclYiyang && self <= PtclBan
#   end

#   # phrase

#   def phrases?
#     self >= SubjVerb && self < Onomat
#   end

#   def morpheme?
#     self >= SufNoun && self < VerbOrNoun
#   end

#   def suffixes?
#     self >= SufNoun && self < Prefix
#   end

#   def prefixes?
#     self >= Prefix && self < VerbOrNoun
#   end

#   # words that have multi meaning/part-of-speech
#   def polysemy?
#     false
#   end

#   # special words that need to be check before build semantic tree
#   def uniqword?
#     self >= VcomplOrX
#   end

#   def qt_to_nq
#     (self >= Qtverb) && (self <= Qttime) ? self + (Nqverb.value - Qtverb.value) : Nqnoun
#   end
# end

# module MT::HasTag
#   property tag = MtlTag::LitBlank
#   forward_missing_to @tag

#   # words after this is most certainly noun words/noun phrases
#   def mark_noun_after?
#     @tag.quantis? || @tag.mod_prons?
#   end
# end

# # puts MT::MtlTag.values.size
