const minute_span = 60
const hour_span = minute_span * 60
const day_span = hour_span * 24
const month_span = day_span * 30

export default function relative_time(time = 0, seed = '') {
  const date = new Date(time)
  const span = (new Date().getTime() - time) / 1000

  switch (seed) {
    case '69shu':
    case 'zhwenpg':
    case 'biquge5200':
      if (span < day_span) return 'hôm nay'
      else return get_fulldate(date)
    default:
      if (span > month_span) return get_fulldate(date)
      if (span > day_span) return `${Math.ceil(span / day_span)} ngày trước`
      if (span > hour_span) return `${Math.ceil(span / hour_span)} giờ trước`
      return `${Math.ceil(span / minute_span)} phút trước`
  }
}

function get_fulldate(date) {
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  return `${year}-${month < 10 ? '0' : ''}${month}-${day < 10 ? '0' : ''}${day}`
}
