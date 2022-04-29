<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { map_status } from '$utils/nvinfo_utils'

  import { SIcon } from '$gui'
  import Replies from './Replies.svelte'

  export let crit: CV.Yscrit

  export let show_book = true
  export let show_list = true

  export let view_all = crit.vhtml.length < 640
  export let big_text = false

  let active_repls = false
  let replies = []

  function dup_stars(count: number) {
    return Array(count).fill('⭐').join('')
  }

  async function show_replies() {
    const res = await fetch(`/api/yscrits/${crit.id}/replies`, {
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

  $: book = crit.book
</script>

<crit-item>
  <header>
    <a class="meta _user" href="/crits?by={crit.op_id}">{crit.uname}</a>
    <x-sep>·</x-sep>
    <a class="meta _time" href="/qtran/crits/{crit.id}"
      >{rel_time(crit.utime)}{#if crit.utime != crit.ctime}*{/if}</a>
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
    </div>
  </header>

  {#if show_book && book}
    <section class="book">
      <a class="bcover" href="/-{book.bslug}">
        <img src="/covers/{book.bcover}" alt="" />
      </a>

      <div class="book-info">
        <div class="book-title">
          <a class="link _title" href="/-{book.bslug}">
            <span>{book.btitle}</span>
          </a>
        </div>
        <div class="book-extra">
          <a class="link _author" href="/books/={book.author}">
            <SIcon name="edit" />
            <span>{book.author}</span>
          </a>

          <a class="link _genre" href="/books/-{book.bgenre}">
            <SIcon name="folder" />
            <span>{book.bgenre}</span>
          </a>
        </div>
        <div class="book-extra">
          <span class="meta">
            <SIcon name="activity" />
            <span>{map_status(book.status)}</span>
          </span>

          <span class="meta">
            <SIcon name="clock" />
            <span>{rel_time(book.update)}</span>
          </span>
        </div>
      </div>

      <div class="book-vote">
        {#if book.voters > 0}
          <div class="book-rating" data-tip="Đánh giá">{book.rating}</div>
          <div class="book-voters" data-tip="Lượt đánh giá" tip-loc="bottom">
            {book.voters} lượt
          </div>
        {/if}
      </div>
    </section>
  {/if}

  <div class="vtags">
    {#each crit.vtags as label}
      <a class="vtag" href="/crits?lb={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text class:_all={view_all}>
    {@html crit.vhtml}
  </section>

  {#if crit.vhtml.length > 600}
    <button
      type="button"
      class="reveal"
      class:_sticky={view_all}
      on:click={() => (view_all = !view_all)}>
      <SIcon name="chevrons-{view_all ? 'up' : 'down'}" />
    </button>
  {/if}

  {#if show_list && crit.yslist_id}
    <footer>
      <a class="link _list" href="/lists/{crit.yslist_id}{crit.yslist_vslug}">
        <SIcon name="bookmarks" />
        <span>{crit.yslist_vname}</span>
        <span>({crit.yslist_count} bộ truyện)</span>
      </a>
    </footer>
  {/if}
</crit-item>

{#if active_repls}
  <Replies {replies} bind:_active={active_repls} />
{/if}

<style lang="scss">
  .book {
    @include flex($gap: 0.5rem);
    @include bgcolor(main);

    // @include border(--bd-soft);
    // @include shadow();

    @include border(--bd-soft, $loc: bottom);
    // margin-top: 0.75rem;
    @include margin-x(auto);

    @include bp-min(pl) {
      padding: 0 var(--gutter);
      // margin: 0 var(--gutter);
      // @include bdradi;
      // @include linesd(--bd-soft);
    }
  }

  .book-info {
    overflow: hidden;
  }

  .book-vote {
    min-width: 3.5rem;
    margin-left: auto;
    margin-right: 0.5rem;
    flex-direction: column;
    @include flex-ca;
  }

  .book-title,
  .book-extra {
    @include flex($gap: 0.5rem);
    line-height: 1.5rem;
  }

  .book-title {
    @include ftsize(md);
    @include fgcolor(secd);
    @include clamp($width: null);
    margin-top: 0.5rem;
  }

  .book-extra {
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .book-rating {
    font-weight: 500;
    margin-bottom: 0.25rem;
    @include ftsize(xl);
  }

  .book-voters {
    @include ftsize(sm);
    font-style: italic;
    line-height: 1rem;
    // max-width: 3.5rem;
    @include fgcolor(tert);
    @include clamp($width: null);
  }

  .bcover {
    height: 100%;
    width: 4rem;

    img {
      width: 100%;
      height: 100%;
    }
  }

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

  header {
    @include flex($gap: 0.25rem);
    position: sticky;
    top: 0;
    z-index: 10;
    padding: 0 var(--gutter);
    line-height: 2.25rem;
    background-color: inherit;

    @include bdradi($loc: top);
    @include border(--bd-soft, $loc: bottom);
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
    background: inherit;
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

  .body {
    --bg-hide: #{color(neutral, 7, 2)};

    padding: 0 var(--gutter);

    line-height: 1.5em;
    position: relative;

    overflow: hidden;
    max-height: 12rem;

    @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));

    @include tm-dark {
      --bg-hide: #{color(neutral, 5, 2)};
    }

    background: linear-gradient(
      to top,
      color(--bg-hide) 0.25rem,
      transparent 0.75rem
    );

    &._all {
      max-height: initial;
      overflow: none;
      background: none;
    }

    &.big_text {
      @include bps(font-size, rem(18px), $pl: rem(19px), $tm: rem(20px));
    }

    :global(p) {
      margin: 0.75em 0;
    }
  }

  .reveal {
    @include flex-ca;
    @include border(--bd-soft, $loc: top);
    @include fgcolor(tert);

    outline: none;
    width: 100%;
    background: inherit;

    height: 1.75rem;

    &._sticky {
      position: sticky;
      bottom: 0;
    }

    @include hover {
      @include bgcolor(neutral, 5, 2);
    }
  }

  footer {
    @include flex($gap: 0.375rem);
    @include border(--bd-soft, $loc: top);

    padding: 0.375rem var(--gutter);
    @include fgcolor(tert);

    // prettier-ignore
    span { @include ftsize(sm); }

    // prettier-ignore
    :global(svg) { margin-bottom: .125rem; }
  }

  .link {
    font-weight: 500;
    // padding: 0.375rem 0;
    flex-shrink: 1;

    color: inherit;
    // @include fgcolor(tert);
    @include clamp($width: null);
    // prettier-ignore
    &:hover { @include fgcolor(primary, 5); }
  }

  .vtags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;

    @include padding-x(var(--gutter));
    // prettier-ignore
    &:not(:empty) { margin-top: 0.75rem; }
  }

  .vtag {
    display: inline-flex;
    align-items: center;
    font-weight: 500;
    @include fgcolor(tert);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
