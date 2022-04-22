<script context="module" lang="ts">
  export async function load({ fetch, url, params: { author } }) {
    const page = +url.searchParams.get('pg') || 1
    const api_url = `/api/books?order=weight&lm=8&pg=${page}&author=${author}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()

    payload.props.author = author
    return payload
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import NvinfoList from '$gui/sects/Nvinfo/List.svelte'

  export let author = ''
  export let books = []
  export let pgidx = 0
  export let pgmax = 0

  $: topbar.set({ left: [[author, 'edit', { href: `/books/=${author}` }]] })
</script>

<svelte:head>
  <title>Tác giả: {author} - Chivi</title>
</svelte:head>

<section>
  <h1>Truyện của tác giả [<em>{author}</em>]</h1>
  <NvinfoList items={books} {pgidx} {pgmax} />
</section>

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
