<script>
  const name = $$props['m-icon'] || 'feather'
</script>

<svg class={$$props.class} m-icon={name}>
  <use xlink:href="/feather.svg#{name}" />
</svg>
