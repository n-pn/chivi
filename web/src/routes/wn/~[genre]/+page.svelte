<script lang="ts">
  import { page } from '$app/stores'

  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Bgenre from '$gui/sects/Bgenre.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax, genres } = data)

  $: pager = new Pager($page.url, { order: 'bumped', pg: 1 })
</script>

<div class="filter">
  <Bgenre {genres} />
</div>

{#if books.length > 0}
  <WninfoList {books} />
{:else}
  <div class="u-empty">Danh sách trống</div>
{/if}

<Footer>
  <Mpager {pager} {pgidx} {pgmax} />
</Footer>

<style lang="scss">
  :global(#svelte) {
    height: 100%;
  }

  .filter {
    @include margin-y(1.5rem);
  }
</style>
