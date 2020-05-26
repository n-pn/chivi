const minute_span = 60
const hour_span = minute_span * 60
const day_span = hour_span * 24
const month_span = day_span * 30

export default function relative_time(time) {
  const span = (new Date().getTime() - time) / 1000

  if (span < minute_span) return '< 1 phút trước'
  if (span < hour_span) return `${Math.round(span / minute_span)} phút trước`
  if (span < day_span) return `${Math.round(span / hour_span)} giờ trước`
  if (span < month_span) return `${Math.round(span / day_span)} giờ trước`

  return new Date(time).toISOString().split('T')[0]
}
