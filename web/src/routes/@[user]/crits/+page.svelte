<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ vi, sort = 'utime' } = data)
</script>

<WncritList {vi} _sort={sort} show_book={true} view_head={false} />
