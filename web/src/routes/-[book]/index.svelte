<script context="module">
  export async function load({ fetch, context, page: { query } }) {
    const { nvinfo } = context
    const page = +query.get('page') || 1

    const res = await fetch(`/api/crits?book=${nvinfo.id}&page=${page}`)
    return { props: { nvinfo, ...(await res.json()) } }
  }
</script>

<script>
  import { page } from '$app/stores'

  import Mpager, { Pager } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import Book from './_book.svelte'

  export let nvinfo

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.path, $page.query, { order: 'bumped' })
  let short_intro = false
</script>

<Book {nvinfo} nvtab="index">
  <article class="m-article">
    <h2>Giới thiệu:</h2>
    <div class="intro" class:_short={short_intro}>
      {#each nvinfo.bintro as para}
        <p>{para}</p>
      {/each}
    </div>

    <h2>Đánh giá:</h2>
    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} show_book={false} view_all={crit.vhtml.length < 1000} />
      {/each}

      <footer class="pagi">
        {#if crits.length > 0}
          <Mpager {pager} {pgidx} {pgmax} />
        {/if}
      </footer>
    </div>
  </article>
</Book>

<style lang="scss">
  article {
    @include fluid(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include fluid(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  .intro {
    word-wrap: break-word;
    @include fgcolor(neutral, 7);
    // @include fluid(padding, $md: 0 0.75rem);
    @include fluid(font-size, rem(15px), rem(16px), rem(17px));

    @include tm-dark {
      @include fgcolor(neutral, 3);
    }

    &._short {
      height: 20rem;
      overflow-y: scroll;
      scrollbar-width: thin;
      scrollbar-color: color(gray, 8);
    }
  }

  p {
    margin-top: 0.5rem;
  }
</style>
