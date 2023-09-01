<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import { toggle_like } from '$utils/memo_utils'

  import { SIcon, Stars } from '$gui'
  import Truncate from '$gui/atoms/Truncate.svelte'
  import YscritBook from './YscritBook.svelte'

  export let crit: CV.Vicrit
  export let book: CV.Wninfo | undefined

  export let show_book = true
  export let show_list = true

  export let view_all = crit.ohtml.length < 600
  export let big_text = false

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like(
      'vicrit',
      crit.vc_id,
      crit.me_liked,
      ({ like_count, memo_liked }) => {
        crit.like_count = like_count
        crit.me_liked = memo_liked
      }
    )
  }

  $: crit_path = `/wn/${crit.b_uslug}/uc/v${crit.vc_id}`
  $: edit_path = `/wn/${crit.b_uslug}/uc/+crit?id=${crit.vc_id}`
  $: list_path = `/@${crit.u_uname}/lists/${crit.l_uslug}`
</script>

<article class="crit island">
  <header class="head">
    <a
      class="m-meta _user cv-user"
      data-privi={crit.u_privi}
      href="/wn/crits?from=vi&user={crit.u_uname}">{crit.u_uname}</a>

    <span class="u-fg-tert">&middot;</span>
    <span class="m-meta _time"
      >{rel_time(crit.ctime)}{crit.utime > crit.ctime ? '*' : ''}</span>

    <div class="right">
      <span class="m-meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <div class="vtags">
    {#each crit.btags as label}
      <a class="vtag" href="/wn/crits?vtag={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text>
    <Truncate html={crit.ohtml} {view_all} />
  </section>

  <footer class="foot" class:_sticky={view_all}>
    <!-- <span class="m-meta">&middot;</span> -->

    {#if crit.ohtml.length > 600}
      <button class="m-meta" on:click={() => (view_all = !view_all)}>
        <SIcon name="chevrons-{view_all ? 'up' : 'down'}" />
        <span>{view_all ? 'Thu hẹp' : 'Mở rộng'}</span>
      </button>
    {/if}

    <a class="m-meta" href="{crit_path}#vcrit">
      <SIcon name="link" />
      <span>Liên kết</span>
    </a>

    {#if $_user.uname == crit.u_uname}
      <a class="m-meta" href={edit_path}>
        <SIcon name="pencil" />
        <span>Sửa chữa</span>
      </a>
    {/if}

    <div class="right">
      <button
        class="m-meta"
        type="button"
        on:click={handle_like}
        class:_active={crit.me_liked > 0}>
        <SIcon name="thumb-up" />
        <span class="u-show-pm">Ưa thích</span>
        <span class="m-badge">{crit.like_count}</span>
      </button>

      <a class="m-meta" href="{crit_path}#repls">
        <SIcon name="message" />
        <span class="u-show-pm">Phản hồi</span>
        <span class="m-badge">{crit.repl_count}</span>
      </a>
    </div>
  </footer>

  {#if show_list}
    <footer class="list">
      <a class="link _list" href={list_path}>
        <SIcon name="bookmarks" />
        <span>{crit.l_title}</span>
        <span>({crit.l_count} bộ truyện)</span>
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

  .m-meta {
    &._user {
      font-weight: 500;
      @include clamp($width: null);
      @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
      // flex-shrink: 0;
    }

    &._star :global(.star) {
      width: 1.1em;
      height: 1.1em;
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
