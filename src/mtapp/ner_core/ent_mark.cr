@[Flags]
enum MT::EntMark : UInt64
  # detect foreign words
  WORD # raw string
  LINK # url
  MATH # math
  FRAG # unknown fragment
  # MAIL # email

  #

  DATE # Date
  DURA # Duration
  TIME # Time

  ###

  NPER # Person
  NNRP # Nationalities or religious or political groups

  NLOC # Location
  NGPE # Countries, cities, states

  NORG # Organization
  NFAC # Buildings, airports, highways, bridges, etc.

  NPRD # Vehicles, weapons, foods, etc. (Not services)
  NEVT # Named hurricanes, battles, wars, sports events, etc.
  NTTL # Titles of books, songs, etc.
  # N_LAW # Named documents made into laws

  # S_PHO # PHONE
  # S_TEL # TELEX
  # S_FAX # FAX
  # S_POS # POSTALCODE

  # numbers:

  # mark generic nmumber
  DNUM # cardinal
  DORD # ordinal

  DINT # pure digital
  DLIT # han letters
  DMIX # mix digit and hanzi

  DPCT # Percent
  DMON # Money
  DFRE # Frequency
  DFRA # Fraction
  DDEC # Decimal
  DRAT # Rate

  # measure
  MAGE # Age
  MWEI # Weight
  MLEN # Length
  MTEM # Temperature
  MANG # Angle
  MARE # Area
  MCAP # Capacity
  MSPE # Speed
  MACC # Acceleration
  MMEA # Other measures

end

enum MT::NerMark : UInt8
  B
  I
  E
  S
end
