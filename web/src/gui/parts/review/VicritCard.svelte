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

  export let view_all = false
  export let big_text = false

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like('vicrit', crit.vc_id, crit.me_liked, ({ like_count, memo_liked }) => {
      crit.like_count = like_count
      crit.me_liked = memo_liked
    })
  }

  $: crit_path = `/uc/crits/@${crit.u_uname}/c${crit.vc_id}`
  $: edit_path = `/uc/crits/+crit?id=${crit.vc_id}&wn=${crit.wn_id}`
  $: list_path = `/ul/lists/@${crit.u_uname}/l${crit.l_uslug}`
</script>

<article class="crit island">
  <header class="head">
    <a class="cv-user" data-privi={crit.u_privi} href="/uc/crits/@{crit.u_uname}">{crit.u_uname}</a>
    <span class="u-fg-tert">&middot;</span>
    <span class="m-meta _time">{rel_time(crit.ctime)}{crit.utime > crit.ctime ? '*' : ''}</span>
    <span class="u-fg-tert">&middot;</span>
    <a href={crit_path} class="m-meta"><em>Liên kết</em></a>

    <div class="stars m-flex _cx u-right">
      <span class="m-meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <div class="vtags" class:big_text>
    {#each crit.btags as label}
      <a class="vtag" href="/uc/crits?lb={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text>
    <Truncate html={crit.ohtml} bind:view_all />
  </section>

  <footer class="foot" class:_sticky={view_all}>
    {#if $_user.uname == crit.u_uname || $_user.privi > 3}
      <a class="m-meta" href={edit_path}>
        <SIcon name="pencil" />
        <span>Sửa chữa</span>
      </a>
    {/if}

    <div class="u-right">
      <button class="m-meta" type="button" on:click={handle_like} class:_active={crit.me_liked > 0}>
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
    @include padding-y(0);
    @include bgcolor(tert);

    // @include bdradi();
    @include linesd(--bd-soft, $inset: false);

    & + :global(.crit) {
      margin-top: 1rem;
    }
  }

  .head {
    @include flex($gap: 0.25rem);
    position: sticky;
    top: 0;
    z-index: 10;
    padding: 0.375rem var(--gutter);

    // line-height: 2.25rem;

    @include bgcolor(tert);
    @include border(--bd-soft, $loc: bottom);

    &:first-child {
      @include bdradi($loc: top);
    }
  }

  .m-meta {
    &._star :global(.star) {
      width: 1.25em;
      height: 1.25em;
    }
  }

  .cv-user {
    font-weight: 500;
    @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
    @include clamp($width: null);
    max-width: 30vw;
    // flex-shrink: 0;
  }

  .vtags {
    &.big_text {
      @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));
    }

    + .body :global(p):first-of-type {
      margin-top: 0;
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

    --line: 6;
    // prettier-ignore
    @include bp-min(ts) { --line: 8; }
    // prettier-ignore
    @include bp-min(ds) { --line: 6; }
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
