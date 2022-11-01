<script lang="ts">
  import { Crumb } from '$gui'
  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, pgidx, pgmax } = data)
</script>

<Crumb tree={[['Thư đơn', '/lists']]} />

<article class="article">
  <YslistList {lists} {pgidx} {pgmax} />
</article>
