<script context="module">
  export async function load({ fetch, url: { searchParams } }) {
    const page = +searchParams.get('page') || 1
    const type = searchParams.get('t') || 'btitle'

    const input = searchParams.get('q')
    if (!input) return { props: { input, type } }

    const qs = input.replace(/\+|-/g, ' ')
    const url = `/api/books?order=weight&take=8&page=${page}&${type}=${qs}`
    const res = await fetch(url)
    return { props: { input, type, ...(await res.json()) } }
  }
</script>

<script>
  import { data as appbar } from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import NvinfoList from '$sects/Nvinfo/List.svelte'

  export let input = ''
  export let books = []
  export let pgidx = 0
  export let pgmax = 0

  $: from = (pgidx - 1) * 8 + 1
  $: upto = from + books.length - 1
  $: appbar.set({ query: input })
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{input}" - Chivi</title>
</svelte:head>

<Vessel>
  {#if pgmax > 0}
    <h1>Hiển thị kết quả từ {from} tới {upto} cho từ khoá "{input}":</h1>
  {:else}
    <h1>Không tìm được kết quả phù hợp cho từ khoá "{input}"</h1>
  {/if}

  <NvinfoList items={books} {pgidx} {pgmax} />
</Vessel>

<style lang="scss">
  h1 {
    text-align: center;
    @include fgcolor(secd, 6);

    @include bps(margin-top, 1rem, 1.5rem, 2rem);
    @include bps(margin-bottom, 0rem, 0.5rem, 1rem);
    @include bps(font-size, font-size(5), font-size(6), font-size(7));
    @include bps(line-height, 1.5rem, 1.75rem, 2rem);
  }
</style>
