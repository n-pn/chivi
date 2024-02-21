<script lang="ts">
  export let name = 'x'
  export let iset = 'tabler'
  export let spin = false
</script>

<svg class="m-icon _{name} {$$props.class || ''}" class:a-spin={spin}>
  <use xlink:href="/icons/{iset}.svg#{name}" />
</svg>
