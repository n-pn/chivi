<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { SIcon, Gmenu } from '$gui'
  import Replies from './Yscrit/Replies.svelte'

  export let crit: CV.Yscrit
  export let show_book = true
  export let view_all = false
  export let big_text = false

  let active_repls = false
  let replies = []

  function get_stars(count: number) {
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
    <a class="user" href="/crits?user={crit.uslug}">{crit.uname}</a>
    <x-sep>·</x-sep>
    <a class="time" href="/qtran/crits/{crit.id}">{rel_time(crit.mftime)}</a>
    <crit-star>{get_stars(crit.stars)}</crit-star>
    {#if crit.vhtml.length >= 640}
      <button class="m-btn _sm _show" on:click={() => (view_all = !view_all)}>
        <SIcon name={view_all ? 'minus' : 'plus'} />
      </button>
    {/if}

    <Gmenu dir="right">
      <button class="m-btn _sm _menu" slot="trigger">
        <SIcon name="dots-vertical" />
      </button>

      <svelte:fragment slot="content">
        <a class="-item" href="/crits/{crit.id}">
          <SIcon name="link" />
          <span>Đường dẫn</span>
        </a>

        <a class="-item" href="/qtran/crits/{crit.id}">
          <SIcon name="bolt" />
          <span>Dịch nhanh</span>
        </a>
      </svelte:fragment>
    </Gmenu>
  </crit-head>

  <crit-body class:_all={view_all} class:big_text>
    {@html crit.vhtml}
  </crit-body>

  <crit-foot>
    {#if show_book}
      <x-meta>
        <a class="link _title" href="/-{crit.bslug}">
          <SIcon name="book" />
          <span>{crit.bname}</span>
        </a>

        <a class="link _author" href="/books/={crit.author}">
          <SIcon name="edit" />
          <span>{crit.author}</span>
        </a>

        <a class="link _genre" href="/books/-{crit.bgenre}">
          <SIcon name="folder" />
          <span>{crit.bgenre}</span>
        </a>
      </x-meta>
    {/if}

    <x-like>
      <SIcon name="thumb-up" />
      <span>{crit.like_count}</span>
    </x-like>

    <x-repl on:click={show_replies}>
      <SIcon name="message" />
      <span>{crit.repl_count}</span>
    </x-repl>
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

    @include tm-dark {
      @include linesd(--bd-soft, $inset: false);
    }
  }

  crit-head {
    @include flex($gap: 0.25rem);
    position: sticky;
    top: 0;
    z-index: 9;

    @include bgcolor(secd);
    @include bdradi($loc: top);

    padding: 0.25rem 0 0.5rem var(--gutter);
    line-height: 2rem;
    @include bps(font-size, rem(14px), rem(15px), rem(16px));

    button {
      --linesd: 0;
      background: inherit;
    }

    ._show {
      margin-left: -0.25rem;
      margin-right: -0.75rem;
    }
  }

  .user,
  .time {
    @include fgcolor(secd);
    @include clamp($width: null);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .user {
    font-weight: 500;
    max-width: 36vw;
  }

  .time {
    @include fgcolor(tert);
  }

  crit-star {
    @include ftsize(sm);
    margin-left: auto;
  }

  crit-body {
    display: block;
    margin: 0 var(--gutter);
    @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));

    max-height: 12rem;
    overflow: hidden;

    --hide: #{color(neutral, 7, 2)};
    // prettier-ignore
    background: linear-gradient( to top, color(--hide) 0.25rem, transparent 1rem);

    @include tm-dark {
      --hide: #{color(neutral, 5, 2)};
    }

    &._all {
      max-height: initial;
      overflow: none;
      background: none;
    }

    &.big_text {
      @include bps(font-size, rem(18px), $pl: rem(19px), $tm: rem(20px));
    }

    :global(p) {
      line-height: 1.5em;
      margin-bottom: 1em !important;
    }
  }

  crit-foot {
    margin: 0 var(--gutter);
    padding: 0.5rem 0;

    @include flex($gap: 1rem);
    justify-content: right;
    @include border(--bd-main, $loc: top);

    @include fgcolor(tert);

    // prettier-ignore
    span { @include ftsize(sm); }

    // prettier-ignore
    :global(svg) { margin-bottom: .125rem; }
  }

  x-meta {
    flex: 1;
    @include flex($gap: 0.375rem);
  }

  .link {
    font-weight: 500;
    @include clamp($width: null);

    @include fgcolor(tert);
    @include hover {
      @include fgcolor(primary, 5);
    }

    &._title {
      @include bps(max-width, 55vw, 60vw, $ts: 35vw);
    }

    &._author {
      max-width: 25vw;
      @include bps(display, none, $ts: inline-block);
    }

    &._genre {
      @include bps(display, none, $tm: inline-block);
    }
  }

  x-repl {
    @include hover {
      cursor: pointer;
    }
  }

  x-like {
    margin-left: auto;
  }
</style>
