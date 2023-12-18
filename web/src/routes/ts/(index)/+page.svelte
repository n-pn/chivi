<script lang="ts">
  import TsrepoList from '$gui/shared/tsrepo/TsrepoList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ items, pgidx, pgmax } = data.table)
</script>

<TsrepoList {items} {pgidx} {pgmax} />
