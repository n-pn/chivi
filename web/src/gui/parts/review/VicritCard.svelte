<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_path } from '$lib/api_call'
  import { rel_time } from '$utils/time_utils'

  import { SIcon, Stars } from '$gui'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import YscritBook from './YscritBook.svelte'

  export let crit: CV.Vicrit
  export let book: CV.Wninfo
  export let user: CV.Viuser
  export let list: CV.Vilist

  export let show_book = true
  export let show_list = true

  export let view_all = crit.ohtml.length < 600
  export let big_text = false

  let show_repls = false
  let replies = []

  async function show_replies() {
    const extra = { crit: crit.id, order: 'ctime' }
    const path = api_path('/_db/virepls', null, null, extra)
    replies = await fetch(path).then((r: Response) => r.json())
    show_repls = true
  }

  $: edit_path = `/wn/${book.bslug}/crits/+crit?id=${crit.id}`
</script>

<article class="crit island">
  <header class="head">
    <a
      class="meta _user cv-user"
      data-privi={user.privi}
      href="/wn/crits?from=vi&user={user.uname}">{user.uname}</a>

    <span class="meta _time">
      <SIcon name="clock" />
      <span>{rel_time(crit.ctime)}{crit.edited ? '*' : ''}</span>
    </span>

    <div class="right">
      <span class="meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <div class="vtags">
    {#each crit.btags as label}
      <a class="vtag" href="/wn/crits?lb={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text>
    <Truncate html={crit.ohtml} {view_all} />
  </section>

  <footer class="foot" class:_sticky={view_all}>
    <!-- <span class="meta">&middot;</span> -->

    <a class="meta" href="/wn/crits/v-{crit.id}">
      <SIcon name="link" />
      <span>Liên kết</span>
    </a>

    {#if $_user.privi > 3 || $_user.uname == user.uname}
      <a class="meta" href={edit_path}>
        <SIcon name="pencil" />
        <span>Sửa chữa</span>
      </a>
    {/if}

    {#if crit.ohtml.length > 600}
      <button class="meta" on:click={() => (view_all = !view_all)}>
        <SIcon name="chevrons-{view_all ? 'up' : 'down'}" />
        <span>{view_all ? 'Thu hẹp' : 'Mở rộng'}</span>
      </button>
    {/if}

    <div class="right">
      <span class="meta">
        <SIcon name="thumb-up" />
        <span class="u-show-pl">Ưa thích</span>
        <span class="badge">{crit.like_count}</span>
      </span>

      <button class="meta" on:click={show_replies}>
        <SIcon name="message" />
        <span class="u-show-pl">Phản hồi</span>
        <span class="badge">{crit.repl_count}</span>
      </button>
    </div>
  </footer>

  {#if show_list && list}
    <footer class="list">
      <a class="link _list" href="/wn/lists/v-{list.id}-{list.tslug}">
        <SIcon name="bookmarks" />
        <span>{list.title}</span>
        <span>({list.book_count} bộ truyện)</span>
      </a>
    </footer>
  {/if}
</article>

<style lang="scss">
  .crit {
    display: block;
    @include margin-y(1rem);
    @include padding-y(0);

    @include bgcolor(tert);

    // @include bdradi();
    @include linesd(--bd-main, $inset: false);
  }

  .head {
    @include flex($gap: 0.25rem);
    position: sticky;
    top: 0;
    z-index: 10;
    padding: 0 var(--gutter);
    line-height: 2.25rem;

    @include bgcolor(tert);
    @include border(--bd-soft, $loc: bottom);

    &:first-child {
      @include bdradi($loc: top);
    }
  }

  .right {
    display: flex;
    margin-left: auto;
    @include flex($gap: 0.375rem);
  }

  .meta {
    display: inline-flex;
    gap: 0.125rem;
    align-items: center;

    @include bps(font-size, rem(12px), $pl: rem(13px), $tm: rem(14px));

    &._user {
      font-weight: 500;
      @include clamp($width: null);
      @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
      // flex-shrink: 0;
    }

    &:not(.cv-user) {
      @include fgcolor(tert);
    }

    :global(.m-icon) {
      width: 1.1em;
      height: 1.1em;
      @include fgcolor(mute);
    }

    &._star :global(.star) {
      width: 1.1em;
      height: 1.1em;
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

  .body {
    padding: 0.375rem var(--gutter) 0.25rem;
    position: relative;
    line-height: 1.5em;

    @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));

    &.big_text {
      @include bps(font-size, rem(18px), $pl: rem(19px), $tm: rem(20px));
    }

    :global(p + p) {
      margin-top: 0.75em;
    }

    --line: 12;
    // prettier-ignore
    @include bp-min(ts) { --line: 10; }
    // prettier-ignore
    @include bp-min(ds) { --line: 8; }
  }

  footer {
    @include flex($gap: 0.375rem);
    @include fgcolor(tert);

    span {
      @include ftsize(sm);
    }
  }

  .foot {
    padding: 0.5rem var(--gutter);
  }

  .list {
    padding: 0.25rem var(--gutter);

    @include border(--bd-soft, $loc: top);
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
