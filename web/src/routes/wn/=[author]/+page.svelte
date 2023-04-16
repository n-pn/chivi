<script lang="ts">
  import WninfoList from '$gui/parts/wninfo/WninfoList2.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books, pgidx, pgmax, author } = data)
</script>

<svelte:head>
  <title>Tác giả: {author} - Chivi</title>
</svelte:head>

<section>
  <h1>Truyện của tác giả [<em>{author}</em>]</h1>
  <WninfoList items={books} {pgidx} {pgmax} />
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
