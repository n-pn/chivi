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

<crit-item>
  <crit-head>
    <a class="crit-user" href="/crits?user={crit.uslug}">{crit.uname}</a>
    <crit-sep>·</crit-sep>
    <a class="crit-time" href="/crits/{crit.id}">{get_rtime(crit.mftime)}</a>
    <crit-star>{get_stars(crit.stars)}</crit-star>
    {#if crit.vhtml.length >= 1000}
      <button class="m-button btn-sm" on:click={() => (view_all = !view_all)}>
        <SIcon name={view_all ? 'minus' : 'plus'} />
      </button>
    {/if}
  </crit-head>

  <crit-body class:_all={view_all}>
    <slot>{@html crit.vhtml}</slot>
  </crit-body>

  <crit-foot>
    {#if show_book}
      <crit-meta>
        <a class="crit-link _title" href="/-{crit.bslug}">
          <SIcon name="book" />
          <span>{crit.bname}</span>
        </a>

        <a class="crit-link _author" href="/search?q={crit.author}&t=author">
          <SIcon name="edit" />
          <span>{crit.author}</span>
        </a>

        <a class="crit-link _genre" href="/?genre={crit.bgenre}">
          <SIcon name="folder" />
          <span>{crit.bgenre}</span>
        </a>
      </crit-meta>
    {/if}

    <crit-like>
      <SIcon name="thumb-up" />
      <span>{crit.like_count}</span>
    </crit-like>

    <crit-repl on:click={show_replies}>
      <SIcon name="message" />
      <span>{crit.repl_count}</span>
    </crit-repl>
  </crit-foot>
</crit-item>

{#if active_repls}
  <Replies {replies} bind:_active={active_repls} />
{/if}

<style lang="scss">
  crit-item {
    display: block;
    margin: 1rem 0;
    @include shadow();
    @include bdradi();
    @include bgcolor(secd);
  }

  crit-head {
    @include flex($gap: 0.3rem);
    position: sticky;
    top: 0;
    z-index: 9;

    @include bgcolor(secd);
    @include bdradi($loc: top);

    padding: 0.5rem var(--gutter);
    line-height: 2rem;
    @include bps(font-size, rem(14px), rem(15px), rem(16px));

    button {
      --linesd: 0;
      background: inherit;
    }
  }

  .crit-user,
  .crit-time {
    @include fgcolor(secd);
    @include clamp($width: null);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .crit-user {
    font-weight: 500;
    max-width: 36vw;
  }

  .crit-time {
    @include fgcolor(tert);
  }

  crit-star {
    @include ftsize(sm);
    margin-left: auto;
  }

  crit-body {
    display: block;
    padding: 0 var(--gutter);
    @include bps(font-size, rem(16px), rem(17px));

    max-height: 15rem;
    overflow: hidden;

    &._all {
      overflow: none;
      max-height: initial;
    }

    :global(p) {
      margin-bottom: 1rem !important;
    }
  }

  crit-foot {
    margin: 0 var(--gutter);
    padding: 0.5rem 0;

    @include flex($gap: 1rem);
    justify-content: right;
    @include border(--bd-main, $loc: top);

    @include fgcolor(tert);

    > * {
      @include ftsize(sm);
    }
  }

  crit-meta {
    flex: 1;
    @include flex($gap: 0.375rem);
  }

  .crit-link {
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

  crit-repl {
    @include hover {
      cursor: pointer;
    }
  }

  crit-like {
    margin-left: auto;
  }
</style>
