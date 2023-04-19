require "../_base"
require "./wninfo"

class CV::Nvstat
  enum Klass
    # ## combine of chivi, yousuu, ... stats
    NvWeight = 0
    NvVoters = 1
    NvRating = 2

    #

    BookViews = 10 # info view + chapter views
    ChapViews = 11 # only chapter views
    InfoViews = 12 # info page views

    # ## stats generate by chivi users

    CvScores = 100 # voters * rating
    CvVoters = 101
    CvRating = 102 # rating from 0 to 100

    # ## stats from yousuu

    YsScores = 200
    YsVoters = 201
    YsRating = 202
  end

  include Clear::Model
  self.table = "nvstats"

  column nvinfo_id : Int32 = 0

  column klass : Int32 = 0 # type of nvstats
  # timestamp map to integer:
  # eg: 2022/01/01 => 20101 ([2][01][01] => [year][month][day])
  # stamp == 0 => total value
  # stamp > 0 => year = year + 2020
  # day == 0 => stats for whole month
  # month == 0 && day == 0 => stats for whole year
  # month == 0 && day != 0 => stats for week of year (borrow day value)

  column stamp : Int32 = 0
  column value : Int32 = 0

  timestamps

  #########################################

  def self.to_stamp(year : Int32, month : Int32, day : Int32)
    (year &- 2020) &* 10000 &+ month &* 100 &+ day
  end

  def self.day_stamp(time = Time.local)
    to_stamp(time.year, time.month, time.day)
  end

  def self.week_stamp(time = Time.local)
    day_of_year = time.day_of_year &+ 7 &- time.day_of_week.value
    week = day_of_year // 7
    to_stamp(time.year, 0, week)
  end

  def self.month_stamp(time = Time.local)
    to_stamp(time.year, time.month, 0)
  end

  def self.year_stamp(time = Time.local)
    to_stamp(time.year, 0, 0)
  end

  def self.stamps(time = Time.local)
    [
      0,                 # all times
      year_stamp(time),  # this year
      month_stamp(time), # this month
      week_stamp(time),  # this week
      day_stamp(time),   # today
    ]
  end

  #####

  def self.upsert(nvinfo_id : Int64, klass : Klass,
                  stamps = self.stamps(Time.local),
                  value = 1, mode = :inc)
    stamps.each do |stamp|
      values = [nvinfo_id, klass.value, stamp, value]
      case mode
      when :inc then values << value
      when :dec then values << -value
      else           values << 0
      end

      Clear::SQL.execute <<-SQL, values
      insert into nvstats(nvinf_id, klass, stamp, value)
      values ($1, $2, $3, $4, $5)
      on conflict (klass, stamp, nvinfo_id) do update
        set value = nvstats.value + $6
      SQL
    end
  end

  def self.get_value(nvinfo_id : Int64, klass : Klass, stamp : Int32)
    model = {nvinfo_id: nvinfo_id, klass: klass.value, stamp: stamp}
    find(model).try(&.value) || 0
  end

  def self.inc_chap_view(nvinfo_id : Int64)
    upsert(nvinfo_id, :chap_views, value: 1)
    upsert(nvinfo_id, :book_views, value: 1)
  end

  def self.inc_info_view(nvinfo_id : Int64)
    upsert(nvinfo_id, :info_views, value: 1)
    upsert(nvinfo_id, :book_views, value: 1)
  end

  def self.remap_cv_rating(nvinfo_id : Int64, stamps = self.stamps(Time.local))
    stamps.each do |stamp|
      voters = get_value(nvinfo_id, :cv_voters, stamp)
      scores = get_value(nvinfo_id, :cv_scores, stamp)

      if voters < 10
        scores = (10 &- voters) * 50
        voters = 10
      end

      upsert(nvinfo_id, :cv_rating, [stamp], scores // voters, mode: :set)
    end
  end

  def self.remap_nv_weight(nvinfo_id : Int64, stamps = self.stamps(Time.local))
  end

  def self.add_cv_vote(nvinfo_id : Int64, rating : Int32)
    stamps = self.stamps(Time.local)

    scores = upsert(nvinfo_id, :cv_scores, stamps, value: rating)
    voters = upsert(nvinfo_id, :cv_voters, stamps, value: 1)

    puts scores, voters
    remap_cv_rating(nvinfo, stamps)
  end
end
