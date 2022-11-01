<script lang="ts">
  import NvinfoList from '$gui/sects/Nvinfo/List.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ input, books, pgidx, pgmax } = data)
  $: from = (pgidx - 1) * 8 + 1
  $: upto = from + books.length - 1
</script>

<svelte:head>
  <title>Kết quả tìm kiếm cho "{input}" - Chivi</title>
</svelte:head>

<section>
  {#if pgmax > 0}
    <h1>Hiển thị kết quả từ {from} tới {upto} cho từ khoá "{input}":</h1>
  {:else}
    <h1>Không tìm được kết quả phù hợp cho từ khoá "{input}"</h1>
  {/if}

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
