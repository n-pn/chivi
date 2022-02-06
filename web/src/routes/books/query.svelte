<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url }) {
    const pg = +url.searchParams.get('pg') || 1
    const type = url.searchParams.get('t') || 'btitle'
    const input = url.searchParams.get('q')
    appbar.set({ query: input })

    if (!input) return { props: { input, type } }

    const qs = input.replace(/\+|-/g, ' ')
    const api_url = `/api/books?order=weight&lm=8&pg=${pg}&${type}=${qs}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.input = input
    payload.props.type = type
    return payload
  }
</script>

<script>
  import NvinfoList from '$sects/Nvinfo/List.svelte'

  export let input = ''
  export let books = []
  export let pgidx = 0
  export let pgmax = 0

  $: from = (pgidx - 1) * 8 + 1
  $: upto = from + books.length - 1
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{input}" - Chivi</title>
</svelte:head>

{#if pgmax > 0}
  <h1>Hiển thị kết quả từ {from} tới {upto} cho từ khoá "{input}":</h1>
{:else}
  <h1>Không tìm được kết quả phù hợp cho từ khoá "{input}"</h1>
{/if}

<NvinfoList items={books} {pgidx} {pgmax} />

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
