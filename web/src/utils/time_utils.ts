const minute_span = 60 // 60 seconds
const hour_span = minute_span * 60 // 3600 seconds
const day_span = hour_span * 24
const month_span = day_span * 30
const year_span = month_span * 12

export function rel_time(lower: number, upper: Date = new Date(), suffix = ' trước') {
  if (lower < 100000) return 'Không rõ thời gian'
  const diff = upper.getTime() / 1000 - lower
  return rel_time_diff(diff, suffix) || get_dmy(new Date(lower * 1000))
}

export function rel_time_diff(diff: number, suffix = ' trước') {
  if (diff < hour_span) return `${round(diff, minute_span)} phút${suffix}`
  if (diff < day_span * 2) return `${round(diff, hour_span)} giờ${suffix}`
  if (diff < month_span * 3) return `${round(diff, day_span)} ngày${suffix}`
  if (diff < year_span) return `${round(diff, month_span)} tháng${suffix}`
  return null
}

export function get_dmy(date: Date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${pad_zero(day)}/${pad_zero(month)}/${year}`
}

// for vp term when mtime start from 2020-01-01 00:00:00 time
export function rel_time_vp(mtime: number) {
  return mtime > 1577836800 ? rel_time(mtime) : '~'
}

function pad_zero(input: number) {
  return input.toString().padStart(2, '0')
}

function round(input: number, unit: number) {
  return input <= unit ? 1 : Math.floor(input / unit)
}
