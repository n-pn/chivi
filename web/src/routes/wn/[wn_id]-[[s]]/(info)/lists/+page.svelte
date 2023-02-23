<script lang="ts">
  import YslistList from '$gui/parts/yousuu/YslistList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ lists, users, pgidx, pgmax } = data)
</script>

<YslistList {lists} {users} {pgidx} {pgmax} _sort="score" />
