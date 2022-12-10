<script lang="ts">
  import NvcritList from '$gui/parts/nvcrit/NvcritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<NvcritList ys={data.ys} vi={data.vi} _sort="score" show_book={false} />
