<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'

  export let crit
  export let show_book = true
  export let view_all = false

  function get_stars(count) {
    return Array(count).fill('⭐').join('')
  }
</script>

<div class="crit">
  <header class="-head">
    <span class="-user">{crit.user_name}</span>
    <span class="-time">· {get_rtime(crit.mftime)}</span>
    <span class="-star">{get_stars(crit.stars)}</span>
    {#if crit.vhtml.length >= 1000}
      <button class="m-button btn-sm" on:click={() => (view_all = !view_all)}>
        <SIcon name={view_all ? 'minus' : 'plus'} />
      </button>
    {/if}
  </header>

  <section class="-body" class:_all={view_all}>
    {@html crit.vhtml}
  </section>

  <footer class="-foot">
    {#if show_book}
      <a class="-book" href="/-{crit.book_slug}">
        <SIcon name="book" />
        <span>{crit.book_name}</span>
      </a>
    {/if}

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

<style lang="scss">
  .crit {
    margin: 1rem 0;
    @include shadow();
    @include bdradi();
    @include bgcolor(secd);
  }

  .-head {
    @include flex($gap: 0.3rem);
    position: sticky;
    top: 0;
    z-index: 9;
    @include bgcolor(secd);
    @include bdradi($sides: top);
    // @include border(--bd-main, $sides: bottom);

    padding: 0.5rem var(--gutter-small);
    line-height: 2rem;

    .-user {
      font-weight: 500;
      max-width: 36vw;
      @include clamp($width: null);
    }

    .-time {
      @include fgcolor(tert);
    }

    .-star {
      @include ftsize(sm);
      margin-left: auto;
    }

    button {
      --linesd: none !important;
    }
  }

  .-body {
    margin: 0.5rem var(--gutter-small) 1rem;
    @include fluid(font-size, rem(16px), rem(17px));

    max-height: 15rem;
    overflow: hidden;
    &._all {
      overflow: none;
      max-height: unset;
    }

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

  .-book {
    font-weight: 500;
    margin-right: auto;
    @include fgcolor(tert);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
