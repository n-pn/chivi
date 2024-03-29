@[Flags]
enum MT::MtEner
  PUNC
  # foreign words

  FRAG # unknown fragment
  WORD # raw string
  MATH # math
  LINK # url
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
  ZYMD # year month day in chinese letter format
  ZHMS # hour minute second in chinese letter format

  ###

  NPER # Person
  NNRP # Nationalities or religious or political groups

  NLOC # Location
  NGPE # Countries, cities, states

  NORG # Organization
  NFAC # Buildings, airports, highways, bridges, etc.

  NPRD # Vehicles, weapons, foods, etc. (Not services)
  NEVT # Named hurricanes, battles, wars, sports events, etc.
  NWOA # Titles of books, songs, etc.
  # NLAW # Named documents made into laws

end
