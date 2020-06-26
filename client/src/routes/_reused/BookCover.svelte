<script>
  export let name = ''
  export let label = ''
</script>

<picture class="cover {$$props.class}">
  <img src="/covers/{name}.jpg" alt={label} />
</picture>
