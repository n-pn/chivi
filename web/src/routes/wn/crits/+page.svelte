<script lang="ts">
  import WncritList from '$gui/parts/review/WncritList.svelte'
  import WnNavMenu from '../WnNavMenu.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WnNavMenu tab="crits" />

<article class="article island">
  <WncritList ys={data.ys} vi={data.vi} _sort="score" show_book={true} />
</article>
