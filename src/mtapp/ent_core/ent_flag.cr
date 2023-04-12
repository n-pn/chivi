@[Flags]
enum MT::EntFlag : UInt64
  # detect foreign words
  WORD # raw string
  LINK # url
  MATH # math
  # MAIL # email
  FRAG # unknown fragment

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

  DATE # Date
  DURA # Duration
  TIME # Time

  # S_PHO # PHONE
  # S_TEL # TELEX
  # S_FAX # FAX
  # S_POS # POSTALCODE

  # numbers:

  # mark generic nmumber
  D_NUM # cardinal
  D_ORD # ordinal

  D_INT # pure digital
  D_LIT # han letters
  D_MIX # mix digit and hanzi

  D_PCT # Percent
  D_MON # Money
  D_FRE # Frequency
  D_FRA # Fraction
  D_DEC # Decimal
  D_RAT # Rate

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
