<script context="module">
  export async function load({ fetch, context, page: { query } }) {
    const { nvinfo } = context
    const page = +query.get('page') || 1

    const res = await fetch(`/api/crits?book=${nvinfo.id}&page=${page}`)
    return { props: { nvinfo, ...(await res.json()) } }
  }

  function get_stars(count) {
    return Array(count).fill('⭐').join('')
  }
</script>

<script>
  import { page } from '$app/stores'
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'
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
        <div class="crit">
          <header class="-head">
            <span class="-user">{crit.user_name}</span>
            <span class="-time">· {get_rtime(crit.mftime)}</span>
            <span class="-star">{get_stars(crit.stars)}</span>
          </header>

          <section class="-body">
            {@html crit.vhtml}
          </section>

          <footer class="-foot">
            <div class="-like">
              <SIcon name="thumb-up" />
              <span>{crit.like_count}</span>
            </div>
            <div class="-repl">
              <SIcon name="message" />
              <span>{crit.repl_count}</span>
            </div>
          </footer>
        </div>
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

  .crit {
    margin: 1rem 0;
    @include shadow();
    @include bdradi();
    @include bgcolor(secd);
  }

  .-head {
    @include flex($gap: 0.3rem);
    // @include bgcolor(tert);
    // @include border(--bd-main, $sides: bottom);
    padding: 0.75rem var(--gutter-small) 0.25rem;

    .-user {
      font-weight: 500;
      max-width: 30vw;
      @include clamp($width: null);
    }

    .-time {
      @include fgcolor(tert);
    }

    .-star {
      @include ftsize(sm);
      margin-left: auto;
    }
  }

  .-body {
    padding: 0.5rem var(--gutter-small) 1rem;
    @include fluid(font-size, rem(16px), rem(17px));

    :global(p + p) {
      margin-top: 1rem;
    }
  }

  .-foot {
    margin: 0 var(--gutter-small);
    padding: 0.5rem 0;

    @include flex($gap: 1rem);
    justify-content: right;
    @include border(--bd-main, $sides: top);

    @include fgcolor(tert);
    span {
      @include ftsize(sm);
    }
  }
</style>
