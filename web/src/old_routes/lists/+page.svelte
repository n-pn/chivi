<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import { Crumb } from '$gui'

  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  export let lists = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Thư đơn - Chivi</title>
</svelte:head>

<Crumb tree={[['Thư đơn', '/lists']]} />
<article class="article">
  <YslistList {lists} {pgidx} {pgmax} />
</article>
