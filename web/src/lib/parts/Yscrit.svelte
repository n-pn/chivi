<script context="module">
</script>

<script>
  import { get_rtime } from '$atoms/RTime.svelte'
  import SIcon from '$atoms/SIcon.svelte'
  import Replies from './Yscrit/Replies.svelte'

  export let crit
  export let show_book = true
  export let view_all = false

  let active_repls = false
  let replies = []

  function get_stars(count) {
    return Array(count).fill('⭐').join('')
  }

  async function show_replies() {
    const res = await fetch(`/api/crits/${crit.id}/replies`, {
      headers: { 'Content-Type': 'application/json' },
    })

    if (!res.ok) return
    replies = await res.json()
    active_repls = true
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
    <slot />
  </section>

  <footer class="-foot">
    {#if show_book}
      <span class="-meta">
        <a class="-link _title" href="/-{crit.bslug}">
          <SIcon name="book" />
          <span>{crit.bname}</span>
        </a>

        <a class="-link _author" href="/search?q={crit.author}&t=author">
          <SIcon name="edit" />
          <span>{crit.author}</span>
        </a>

        <a class="-link _genre" href="/?genre={crit.bgenre}">
          <SIcon name="folder" />
          <span>{crit.bgenre}</span>
        </a>
      </span>
    {/if}

    <div class="-like">
      <SIcon name="thumb-up" />
      <span>{crit.like_count}</span>
    </div>

    <div class="-repl" on:click={show_replies}>
      <SIcon name="message" />
      <span>{crit.repl_count}</span>
    </div>
  </footer>
</div>

{#if active_repls}
  <Replies {replies} bind:_active={active_repls} />
{/if}

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
    @include bps(font-size, rem(14px), rem(15px), rem(16px));

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
    margin: 0 var(--gutter) 0;
    @include bps(font-size, rem(16px), rem(17px));

    max-height: 15rem;
    overflow: hidden;
    &._all {
      overflow: none;
      max-height: unset;
    }

    :global(p) {
      margin-bottom: 1rem !important;
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
    @include flex($gap: 0.375rem);

    .-link {
      font-weight: 500;
      @include clamp($width: null);

      @include fgcolor(tert);
      @include hover {
        @include fgcolor(primary, 5);
      }

      &._title {
        max-width: 35vw;
      }

      &._author {
        max-width: 25vw;
      }

      &._genre {
        @include bps(display, none, $md: inline-block);
      }
    }
  }
  .-repl {
    @include hover {
      cursor: pointer;
    }
  }
  .-like {
    margin-left: auto;
  }
</style>
