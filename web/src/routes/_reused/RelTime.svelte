<script context="module">
  const minute_span = 60
  const hour_span = minute_span * 60
  const day_span = hour_span * 24
  const month_span = day_span * 30
  const year_span = month_span * 12

  export function relative_time(old_time, new_time = new Date().getTime()) {
    const span = (new_time - old_time) / 1000

    if (span < minute_span) return '1 phút trước'
    if (span < hour_span) return `${Math.round(span / minute_span)} phút trước`
    if (span < day_span) return `${Math.round(span / hour_span)} giờ trước`
    if (span < month_span) return `${Math.round(span / day_span)} ngày trước`
    if (span < year_span) return `${Math.round(span / month_span)} tháng trước`

    const date = new Date(old_time)
    const month = date.getMonth() + 1
    return `${date.getFullYear()}-${month < 10 ? '0' + month : month}`
  }
</script>

<script>
  import { onMount } from 'svelte'
  export let time = 0
  $: rel_time = relative_time(time)

  onMount(() => {
    const interval = setInterval(() => {
      rel_time = relative_time(time)
    }, 1000)

    return () => clearInterval(interval)
  })
</script>

{rel_time}
