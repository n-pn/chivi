<script lang="ts">
  import NvcritList from '$gui/parts/nvcrit/NvcritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
  $: ({ vi, ys } = data)
</script>

<NvcritList {ys} {vi} _sort="score" show_book={false} />
