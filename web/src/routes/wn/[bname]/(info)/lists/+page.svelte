<script lang="ts">
  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, pgidx, pgmax } = data)
</script>

<YslistList {lists} {pgidx} {pgmax} _sort="score" />
