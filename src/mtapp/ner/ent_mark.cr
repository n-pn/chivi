@[Flags]
enum MT::EntMark : UInt64
  # detect foreign words
  WORD # raw string
  LINK # url
  MATH # math
  # MAIL # email
  FRAG # unknown fragment

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

  def self.extract(marks : Enumerable(String))
    bner = iner = ener = sner = None

    marks.each do |entry|
      type, mark = entry.split('-', 2)
      case type[0]
      when 'B' then bner |= parse(mark)
      when 'I' then iner |= parse(mark)
      when 'E' then ener |= parse(mark)
      when 'S' then sner |= parse(mark)
      end
    end

    {bner, iner, ener, sner}
  end
end
