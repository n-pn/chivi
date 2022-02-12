const minute_span = 60 // 60 seconds
const hour_span = minute_span * 60 // 3600 seconds
const day_span = hour_span * 24
const month_span = day_span * 30

export function rel_time(mtime: number) {
  if (mtime < 100000) return 'Không rõ thời gian'

  const span = new Date().getTime() / 1000 - mtime // unit: seconds

  if (span < hour_span) return `${round(span, minute_span)} phút trước`
  if (span < day_span * 2) return `${round(span, hour_span)} giờ trước`
  if (span < month_span * 3) return `${round(span, day_span)} ngày trước`
  if (span < month_span * 12) return `${round(span, month_span)} tháng trước`

  const date = new Date(mtime * 1000)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate() + 1
  return `${year}-${pad_zero(month)}-${pad_zero(day)}`
}

function pad_zero(input: number) {
  return input.toString().padStart(2, '0')
}

function round(input: number, unit: number) {
  return input <= unit ? 1 : Math.floor(input / unit)
}
