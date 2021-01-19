<script context="module">
  const minute_span = 60
  const hour_span = minute_span * 60
  const day_span = hour_span * 24
  const month_span = day_span * 30

  export function reltime_text(m_time, s_name = ' ') {
    const date = new Date(m_time)
    const span = (new Date().getTime() - m_time) / 1000

    if (span > month_span) return iso_date(date)
    if (span > day_span) return `${rounding(span, day_span)} ngày trước`
    if (uncertain(s_name)) return 'hôm nay'
    if (span > hour_span) return `${rounding(span, hour_span)} giờ trước`
    return `${rounding(span, minute_span)} phút trước`
  }

  function uncertain(s_name) {
    switch (s_name) {
      case '69shu':
      case 'zhwenpg':
      case 'bqg_5200':
        return true
      default:
        return false
    }
  }

  function iso_date(input) {
    const year = input.getFullYear()
    const month = input.getMonth() + 1
    const date = input.getDate() + 1

    return `${year}-${pad_zero(month)}-${pad_zero(date)}`
  }

  function pad_zero(input) {
    return input.toString().padStart(2, '0')
  }

  function rounding(input, unit) {
    if (input <= unit) return 1
    return Math.floor(input / unit)
  }
</script>

<script>
  export let m_time = 0
  export let s_name = ''
</script>

<time>{reltime_text(m_time, s_name)}</time>
