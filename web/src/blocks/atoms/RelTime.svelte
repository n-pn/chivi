<script context="module">
  const minute_span = 60
  const hour_span = minute_span * 60
  const day_span = hour_span * 24
  const month_span = day_span * 30

  export function reltime_text(time, seed = ' ') {
    const date = new Date(time)
    const span = (new Date().getTime() - time) / 1000

    if (uncertain(seed)) return span < day_span ? 'hôm nay' : iso_date(date)

    if (span > month_span) return iso_date(date)
    if (span > day_span) return `${rounding(span, day_span)} ngày trước`
    if (span > hour_span) return `${rounding(span, hour_span)} giờ trước`
    return `${rounding(span, minute_span)} phút trước`
  }

  function uncertain(seed) {
    switch (seed) {
      case '69shu':
      case 'zhwenpg':
      case 'biquge5200':
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
    return Math.round((input - 1) / unit) + 1
  }
</script>

<script>
  export let time = 0
  export let seed = ''

  $: text = reltime_text(time, seed)
</script>

<time>{text}</time>
