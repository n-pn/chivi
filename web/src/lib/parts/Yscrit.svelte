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
    <a class="-user" href="/crits?user={crit.uslug}">{crit.uname}</a>
    <span class="-sep">·</span>
    <a class="-time" href="/crits/{crit.id}">{get_rtime(crit.mftime)}</a>
    <span class="-star">{get_stars(crit.stars)}</span>
    {#if crit.vhtml.length >= 1000}
      <button class="m-button btn-sm" on:click={() => (view_all = !view_all)}>
        <SIcon name={view_all ? 'minus' : 'plus'} />
      </button>
    {/if}
  </header>

  <section class="-body" class:_all={view_all}>
    <slot>
      {@html crit.vhtml}
    </slot>
  </section>

  <footer class="-foot">
    {#if show_book}
      <span class="-meta">
        <a class="-link" href="/-{crit.bslug}">
          <SIcon name="book" />
          <span>{crit.bname}</span>
        </a>

        <a class="-link" href="/search?q={crit.author}&t=author">
          <SIcon name="edit" />
          <span>{crit.author}</span>
        </a>
      </span>
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

    padding: 0.5rem var(--gutter);
    line-height: 2rem;
    @include fluid(font-size, rem(14px), rem(15px), rem(16px));

    .-user,
    .-time {
      @include fgcolor(secd);
      @include clamp($width: null);
      &:hover {
        @include fgcolor(primary, 5);
      }
    }

    .-user {
      font-weight: 500;
      max-width: 36vw;
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
    margin: 0.5rem var(--gutter) 1rem;
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
    margin: 0 var(--gutter);
    padding: 0.5rem 0;

    @include flex($gap: 1rem);
    justify-content: right;
    @include border(--bd-main, $sides: top);

    @include fgcolor(tert);
    span {
      @include ftsize(sm);
    }
  }

  .-meta {
    flex: 1;
    @include flex($gap: 0.5rem);
    .-link {
      font-weight: 500;
      @include clamp($width: null);
      max-width: 30vw;

      @include fgcolor(tert);
      @include hover {
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
