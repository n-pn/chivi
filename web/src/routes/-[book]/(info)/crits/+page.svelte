<script lang="ts">
  import YscritList from '$gui/parts/yousuu/YscritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crits, pgidx, pgmax } = data)
</script>

<YscritList {crits} {pgidx} {pgmax} _sort="score" show_book={false} />
