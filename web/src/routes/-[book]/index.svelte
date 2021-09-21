<script context="module">
  export async function load({ fetch, context, page: { query } }) {
    const { cvbook, ubmemo } = context
    const page = +query.get('page') || 1
    const sort = query.get('sort') || 'stars'

    const qs = `page=${page}&sort=${sort}`
    const res = await fetch(`/api/crits?book=${cvbook.id}&${qs}`)

    return { props: { cvbook, ubmemo, _sort: sort, ...(await res.json()) } }
  }

  const sorts = {
    stars: 'Cho điểm',
    likes: 'Ưa thích',
    mtime: 'Gần nhất',
  }

  const _navi = { replace: true, scrollto: '#sorts' }
</script>

<script>
  import { page } from '$app/stores'

  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import Book from './_book.svelte'

  export let cvbook
  export let ubmemo

  export let crits = []
  export let pgidx = 1
  export let pgmax = 1
  export let _sort

  $: pager = new Pager($page.path, $page.query, { sort: 'stars', page: 1 })
  let short_intro = false
</script>

<Book {cvbook} {ubmemo} nvtab="index">
  <article class="m-article">
    <h2>Giới thiệu:</h2>
    <div class="intro" class:_short={short_intro}>
      {#each cvbook.bintro as para}
        <p>{para}</p>
      {/each}
    </div>

    <div class="sorts" id="sorts">
      <span class="h3 -label">Đánh giá</span>
      {#each Object.entries(sorts) as [sort, name]}
        <a
          href={pager.url({ sort, page: 1 })}
          class="-sort"
          use:navigate={_navi}
          class:_active={sort == _sort}>{name}</a>
      {/each}
    </div>

    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} show_book={false} view_all={crit.vhtml.length < 1000}>
          {@html crit.vhtml}
        </Yscrit>
      {/each}

      <footer class="pagi">
        {#if crits.length > 0}
          <Mpager {pager} {pgidx} {pgmax} {_navi} />
        {/if}
      </footer>
    </div>
  </article>
</Book>

<style lang="scss">
  article {
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  .intro {
    word-wrap: break-word;
    @include fgcolor(neutral, 7);
    // @include bps(padding, $md: 0 0.75rem);
    @include bps(font-size, rem(15px), rem(16px), rem(17px));

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

  .sorts {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);

    .-label {
      flex: 1;
      // font-weight: 500;
      // @include ftsize(xl);
    }

    .-sort {
      @include fgcolor(tert);
      padding: 0 0.125rem;
      height: 2rem;

      &._active {
        border-bottom: 2px solid color(primary, 5);
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
