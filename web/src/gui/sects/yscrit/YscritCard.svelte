<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'
  import Replies from './Replies.svelte'

  export let crit: CV.Yscrit
  export let show_book = true
  export let view_all = false
  export let big_text = false

  let active_repls = false
  let replies = []

  function dup_stars(count: number) {
    return Array(count).fill('⭐').join('')
  }

  async function show_replies() {
    const res = await fetch(`/api/crits/${crit.id}/replies`, {
      headers: { 'Content-Type': 'application/json' },
    })

    const data = await res.json()
    if (!res.ok) {
      alert(data.error)
    } else {
      replies = data.props
      active_repls = true
    }
  }
</script>

<crit-item>
  <crit-head>
    <a class="meta _user" href="/crits?user={crit.uslug}">{crit.uname}</a>
    <x-sep>·</x-sep>
    <a class="meta _time" href="/qtran/crits/{crit.id}"
      >{rel_time(crit.mftime)}</a>
    <a class="meta _link" href="/crits/{crit.id}"><SIcon name="link" /></a>

    <div class="right">
      <span class="meta _star"
        ><x-sm>{crit.stars}⭐</x-sm><x-lg>{dup_stars(crit.stars)}</x-lg></span>
      <span class="meta">
        <SIcon name="thumb-up" />
        <span>{crit.like_count}</span>
      </span>

      <button class="meta" on:click={show_replies}>
        <SIcon name="message" />
        <span>{crit.repl_count}</span>
      </button>

      {#if crit.vhtml.length >= 640}
        <button class="meta _show" on:click={() => (view_all = !view_all)}>
          <SIcon name={view_all ? 'minus' : 'plus'} />
        </button>
      {/if}
    </div>
  </crit-head>

  <crit-body class:_all={view_all} class:big_text>
    {@html crit.vhtml}
  </crit-body>

  {#if show_book}
    <crit-foot>
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
    </crit-foot>
  {/if}
</crit-item>

{#if active_repls}
  <Replies {replies} bind:_active={active_repls} />
{/if}

<style lang="scss">
  crit-item {
    display: block;
    margin: 1rem 0;
    padding-bottom: 0.01px;

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
    z-index: 10;

    @include bgcolor(secd);
    @include bdradi($loc: top);

    padding: 0 var(--gutter);
    line-height: 2.25rem;

    button {
      --linesd: 0;
      background: inherit;
    }
  }

  .right {
    display: flex;
    margin-left: auto;
    @include flex($gap: 0.375rem);
  }

  x-sep {
    @include fgcolor(tert);
  }

  .meta {
    @include fgcolor(tert);
    @include flex-cy($gap: 0.125rem);

    // prettier-ignore
    :global(svg) { width: 1.1em; height: 1.1em; }
    @include bps(font-size, rem(12px), $pl: rem(13px), $tm: rem(14px));

    // prettier-ignore
    &._show {
      margin-left: -0.25rem;
      padding: 0 0.25rem;
      margin-right: calc(var(--gutter) * -0.75);
      @include fgcolor(secd);
      :global(svg) { width: 1.2em; height: 1.2em}
    }

    &._user {
      font-weight: 500;
      @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
      // flex-shrink: 0;
    }

    &._user,
    &._time {
      @include fgcolor(secd);
      @include clamp($width: null);
    }
  }

  a.meta,
  button.meta {
    padding: 0;
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  // prettier-ignore
  ._star {
    margin-left: auto;

    x-lg {display: none;}
    @include bp-min(ts) {
      x-sm { display: none;}
      x-lg { display: inline; }
    }
  }

  crit-body {
    --hide: #{color(neutral, 7, 2)};

    display: block;
    margin: 0 var(--gutter) 1rem;

    max-height: 12rem;
    overflow: hidden;

    @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));
    // prettier-ignore
    background: linear-gradient( to top, color(--hide) 0.25rem, transparent 1rem);
    // prettier-ignore
    @include tm-dark { --hide: #{color(neutral, 5, 2)}; }

    &._all {
      max-height: initial;
      overflow: none;
      background: none;
    }

    &.big_text {
      @include bps(font-size, rem(18px), $pl: rem(19px), $tm: rem(20px));
    }

    :global(p + p) {
      margin-top: 1em !important;
      line-height: 1.5em;
    }
  }

  crit-foot {
    @include flex($gap: 0.375rem);
    @include border(--bd-main, $loc: top);

    margin: 0 var(--gutter);

    @include fgcolor(tert);

    // prettier-ignore
    span { @include ftsize(sm); }

    // prettier-ignore
    :global(svg) { margin-bottom: .125rem; }
  }

  .link {
    font-weight: 500;
    padding: 0.375rem 0;
    flex-shrink: 1;

    @include clamp($width: null);
    @include fgcolor(tert);

    // prettier-ignore
    &:hover { @include fgcolor(primary, 5); }

    &._title {
      max-width: 60vw;
    }

    &._genre {
      @include bps(display, none, $pl: inline-block);
    }
  }
</style>
