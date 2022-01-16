<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ url, fetch, params: { genre } }) {
    const api_url = new URL(url)
    api_url.pathname = '/api/books'
    api_url.searchParams.set('take', 24)
    api_url.searchParams.set('genre', genre)

    const res = await fetch(api_url.toString())
    if (!res.ok) return { status: res.status, error: await res.text() }

    appbar.set({ left: [['Thể loại', 'folder', url.pathname]] })
    return { props: { ...(await res.json()), genres: genre.split('+') } }
  }
</script>

<script>
  import { page } from '$app/stores'
  import Nvlist from '$parts/Nvlist.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Bgenre from '$sects/Bgenre.svelte'

  import Vessel from '$sects/Vessel.svelte'

  export let books = []
  export let pgidx = 1
  export let pgmax = 1
  export let genres = []

  $: pager = new Pager($page.url, { order: 'bumped', page: 1 })
</script>

<svelte:head>
  <title>Chivi - Truyện tàu dịch máy</title>
</svelte:head>

<Vessel>
  <div class="filter">
    <Bgenre {genres} />
  </div>

  {#if books.length > 0}
    <Nvlist {books} />
  {:else}
    <div class="empty">Danh sách trống</div>
  {/if}

  <svelte:fragment slot="footer">
    <Mpager {pager} {pgidx} {pgmax} />
  </svelte:fragment>
</Vessel>

<style lang="scss">
  :global(#svelte) {
    height: 100%;
  }

  .filter {
    margin: 1.5rem 0;
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
