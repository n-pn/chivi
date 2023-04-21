<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'
  import WnNavMenu from '../wn/WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WnNavMenu tab="crits" />

<article class="article island">
  <WncritList
    ys={data.ys || undefined}
    vi={data.vi || undefined}
    _sort={data.sort || 'utime'}
    show_book={true} />
</article>
