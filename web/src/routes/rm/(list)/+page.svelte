<script lang="ts">
  import RmstemList from '$gui/parts/rmstem/RmstemList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ items, pgidx, pgmax } = data.props)
</script>

<RmstemList {items} {pgidx} {pgmax} query={data.query} rpath="/rm" />
