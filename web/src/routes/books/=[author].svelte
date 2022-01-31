<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, url, params: { author } }) {
    const page = +url.searchParams.get('page') || 1
    const api_url = `/api/books?order=weight&take=8&page=${page}&author=${author}`
    const api_res = await fetch(api_url)

    appbar.set({ left: [[author, 'edit', `/books/=${author}`]] })
    return { props: { author, ...(await api_res.json()) } }
  }
</script>

<script>
  import NvinfoList from '$sects/Nvinfo/List.svelte'

  export let author = ''
  export let books = []
  export let pgidx = 0
  export let pgmax = 0
</script>

<svelte:head>
  <title>Tác giả: {author} - Chivi</title>
</svelte:head>

<h1>Truyện của tác giả [<em>{author}</em>]</h1>
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
