<script lang="ts">
  import RmstemList from '$gui/parts/rmstem/RmstemList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ rpath, query, props } = data)
  $: ({ items, pgidx, pgmax } = props)
</script>

<RmstemList {items} {pgidx} {pgmax} {rpath} {query} />
