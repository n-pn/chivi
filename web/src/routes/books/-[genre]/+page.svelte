<script context="module" lang="ts">
  import { wrap_get } from '$lib/api_call'

  export async function load({ url, fetch, params: { genre } }) {
    const api_url = new URL(url)
    api_url.pathname = '/api/books'
    api_url.searchParams.set('lm', '24')
    api_url.searchParams.set('genre', genre)

    const extra = { genres: genre.split('+') }
    const topbar = { left: [['Thể loại', 'folder', { href: url.pathname }]] }

    return await wrap_get(fetch, api_url.toString(), null, extra, { topbar })
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import NvinfoList from '$gui/parts/nvinfo/NvinfoList.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Bgenre from '$gui/sects/Bgenre.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  export let books = []
  export let pgidx = 1
  export let pgmax = 1
  export let genres = []

  $: pager = new Pager($page.url, { order: 'bumped', pg: 1 })
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<div class="filter">
  <Bgenre {genres} />
</div>

{#if books.length > 0}
  <NvinfoList {books} />
{:else}
  <div class="empty">Danh sách trống</div>
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

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(neutral, 6);
  }
</style>
