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
  # NLAW # Named documents made into laws

  DATE # Date
  DURA # Duration
  TIME # Time

  # SPHO # PHONE
  # STEL # TELEX
  # SFAX # FAX
  # SPOS # POSTALCODE

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

@[Flags]
enum MT::EntMark : UInt64
  # foreign words

  FRAG # unknown fragment
  LINK # url
  WORD # raw string
  MATH # math
  # MAIL # email
  # WPHO # PHONE
  # WTEL # TELEX
  # WFAX # FAX
  # WPOS # POSTALCODE

  # numbers:

  DINT # pure digit
  DPCT # Percent (12%)
  DFRA # Fraction (1/2)
  DDEC # Decimal (1.2)

  ZINT # han letters
  ZPCT # han letters
  ZFRA # han letters
  ZDEC # han letters

  DCAR # mix digit and hanzi
  DORD # ordinal

  # DMON # Money (4$)
  # DFRE # Frequency
  # DRAT # Rate

  # measure
  # MAGE # Age
  # MWEI # Weight
  # MLEN # Length
  # MTEM # Temperature
  # MANG # Angle
  # MARE # Area
  # MCAP # Capacity
  # MSPE # Speed
  # MACC # Acceleration
  # MMEA # Other measures
  #

  DYMD # year month day in 2022/20/20 or 2022-10-10 or 20.10.10 format
  DHMS # time in 10:00:00 or 10:10 format
  ZYMD
  ZHMS

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

end
