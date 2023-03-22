<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WncritList
  ys={data.ys || undefined}
  vi={data.vi || undefined}
  _sort={data.sort || 'score'}
  show_book={false} />
