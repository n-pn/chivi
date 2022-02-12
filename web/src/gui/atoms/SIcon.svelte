<script lang="ts">
  export let name = 'x'
  export let iset = 'tabler'
</script>

<svg class="m-icon {$$props.class || '_' + name}">
  <use xlink:href="/icons/{iset}.svg#{name}" />
</svg>
