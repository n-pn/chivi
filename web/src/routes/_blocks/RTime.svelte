<script context="module">
  const minute_span = 60 // 60 seconds
  const hour_span = minute_span * 60 // 3600 seconds
  const day_span = hour_span * 24 * 2
  const month_span = day_span * 30 * 3

  export function reltime_text(mtime, rtime) {
    const span = (new Date().getTime() - mtime) / 1000 // unit: seconds

    if (span > month_span) return iso_date(rtime)
    if (span > day_span) return `${rounding(span, day_span)} ngày trước`
    if (span > hour_span) return `${rounding(span, hour_span)} giờ trước`
    return `${rounding(span, minute_span)} phút trước`
  }

  function iso_date(input) {
    const year = input.getFullYear()
    const month = input.getMonth() + 1
    const day = input.getDate() + 1
    return `${year}-${pad_zero(month)}-${pad_zero(day)}`
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
  export let mtime = 0
  $: rtime = new Date(mtime)
  $: label = reltime_text(mtime, rtime)
</script>

<time datetime={rtime}>{label}</time>
