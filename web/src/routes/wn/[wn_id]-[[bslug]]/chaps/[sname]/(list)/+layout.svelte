<script lang="ts">
  import SeedList from './SeedList.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData
</script>

<SeedList {data} />

<slot />
