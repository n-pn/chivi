<script lang="ts">
  import YscritList from '$gui/parts/yousuu/YscritList.svelte'
  import { Crumb } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crits, books, lists, users, pgidx, pgmax } = data)
</script>

<Crumb tree={[['Đánh giá', '/ys/crits']]} />

<article class="article island">
  <YscritList {crits} {books} {lists} {users} {pgidx} {pgmax} _sort="utime" />
</article>
