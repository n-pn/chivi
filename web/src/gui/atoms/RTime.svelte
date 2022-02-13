<script context="module" lang="ts">
  const minute_span = 60 // 60 seconds
  const hour_span = minute_span * 60 // 3600 seconds
  const day_span = hour_span * 24
  const month_span = day_span * 30

  export function get_rtime(mtime, rtime = new Date(mtime * 1000)) {
    if (mtime < 100000) return 'Không rõ thời gian'
    const span = new Date().getTime() / 1000 - mtime // unit: seconds

    if (span > month_span * 3) return iso_date(rtime)
    if (span > day_span * 2) return `${rounding(span, day_span)} ngày trước`
    if (span > hour_span) return `${rounding(span, hour_span)} giờ trước`
    return `${rounding(span, minute_span)} phút trước`
  }

  function iso_date(rtime) {
    const year = rtime.getFullYear()
    const month = rtime.getMonth() + 1
    const day = rtime.getDate() + 1
    return `${year}-${pad_zero(month)}-${pad_zero(day)}`
  }

  function pad_zero(input) {
    return input.toString().padStart(2, '0')
  }

  function rounding(input, unit) {
    if (input <= unit) return 1
    return Math.floor(input / unit)
  }

  export function get_rtime_short(mtime) {
    const span = new Date().getTime() / 1000 - mtime // unit: seconds

    if (span > month_span * 3) return `${rounding(span, month_span)} tháng`
    if (span > day_span * 2) return `${rounding(span, day_span)} ngày`
    if (span > hour_span) return `${rounding(span, hour_span)} giờ`
    return `${rounding(span, minute_span)} phút`
  }
</script>

<script lang="ts">
  export let mtime = 0
  $: rtime = new Date(mtime * 1000)
</script>

<time datetime={rtime.toDateString()}>{get_rtime(mtime, rtime)}</time>
