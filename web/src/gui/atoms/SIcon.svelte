<script lang="ts">
  export let name = 'x'
  export let iset = 'tabler'
  export let spin = false
</script>

<svg class="m-icon {$$props.class || '_' + name}" class:a-spin={spin}>
  <use xlink:href="/icons/{iset}.svg#{iset}-{name}" />
</svg>
