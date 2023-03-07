<script lang="ts">
  import YslistList from '$gui/parts/review/YslistList.svelte'
  import WnNavMenu from '../WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, users, pgidx, pgmax } = data)
</script>

<WnNavMenu tab="lists" />

<article class="article island">
  <YslistList {lists} {users} {pgidx} {pgmax} _sort="score" />
</article>
