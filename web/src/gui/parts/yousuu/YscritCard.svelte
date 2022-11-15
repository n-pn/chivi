<script context="module" lang="ts">
  import { session } from '$lib/stores'
  import { get_repls } from '$lib/ys_api'
  import { rel_time } from '$utils/time_utils'
</script>

<script lang="ts">
  import Truncate from '$gui/atoms/Truncate.svelte'

  import { SIcon, Stars } from '$gui'
  import YsreplList from './YsreplList.svelte'
  import YscritBook from './YscritBook.svelte'

  export let crit: CV.Yscrit
  export let book = crit.book

  export let show_book = true
  export let show_list = true

  export let view_all = crit.vhtml.length < 600
  export let big_text = false

  let show_repls = false
  let replies = []

  async function show_replies() {
    replies = await get_repls(crit.id)
    show_repls = true
  }

  type BodyType = 'vhtml' | 'btran' | 'deepl'
  let body_type: BodyType = 'vhtml'

  let content = crit.vhtml
  $: swap_content(body_type)

  let cached = {}
  $: cached = { vhtml: crit.vhtml }

  let _loading = false

  async function swap_content(body_type: BodyType) {
    let cached_data = cached[body_type]

    if (cached_data || body_type == 'vhtml') {
      content = cached_data || crit.vhtml
      return
    }

    _loading = true

    const url = `/_ys/crits/${crit.id}/${body_type}`
    const res = await globalThis.fetch(url)
    const res_text = await res.text()
    _loading = false

    if (!res.ok) return alert(res_text)
    cached[body_type] = res_text
    content = res_text
  }

  const body_types = [
    ['vhtml', 'Dịch thô', -1],
    ['btran', 'Bing (Việt)', 2],
    ['deepl', 'DeepL (Eng)', 3],
  ]
</script>

<crit-item>
  <header>
    <a class="meta _user" href="/crits?user={crit.op_id}-{crit.uslug}"
      >{crit.uname}</a>

    <div class="right">
      <span class="meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <section class="version">
    <span class="meta">Dịch theo:</span>
    {#each body_types as [value, label, privi]}
      <label
        class="meta _inline"
        data-tip="Cần thiết quyền hạn tối thiểu: {privi}"
        data-tip-loc="bottom"
        ><input
          type="radio"
          name="{crit.id}_body_type"
          bind:group={body_type}
          disabled={$session.privi < privi}
          {value} />
        <span>{label}</span>
      </label>
    {/each}
  </section>

  <section class="body" class:big_text>
    {#if _loading}
      <div class="loading">
        <SIcon name="loader" spin={_loading} />
        <span>Đang tải dữ liệu</span>
      </div>
    {:else if content == '<p>$$$</p>'}
      <p class="mute">
        <em>(Nội dung đánh giá đã bị ẩn trên Ưu Thư Võng, đợi phục hồi)</em>
      </p>
    {:else}
      <Truncate html={content} {view_all} />
    {/if}
  </section>

  <div class="vtags">
    {#each crit.vtags as label}
      <a class="vtag" href="/crits?lb={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <footer class="foot" class:_sticky={view_all}>
    <!-- <span class="meta">&middot;</span> -->

    <a class="meta _time" href="/qtran/crits/{crit.id}">
      <SIcon name="clock" />
      <span>{rel_time(crit.utime)}{crit.utime != crit.ctime ? '*' : ''}</span>
    </a>

    <a class="meta" href="/crits/{crit.id}">
      <SIcon name="link" />
      <span>Liên kết</span>
    </a>

    {#if content.length > 600}
      <button class="meta" on:click={() => (view_all = !view_all)}>
        <SIcon name="chevrons-{view_all ? 'up' : 'down'}" />
        <span>{view_all ? 'Thu hẹp' : 'Mở rộng'}</span>
      </button>
    {/if}

    <div class="right">
      <span class="meta">
        <SIcon name="thumb-up" />
        <span>{crit.like_count}</span>
      </span>

      <button class="meta" on:click={show_replies}>
        <SIcon name="message" />
        <span>{crit.repl_count}</span>
      </button>
    </div>
  </footer>

  {#if show_list && crit.yslist_id}
    <footer class="list">
      <a class="link _list" href="/lists/{crit.yslist_id}{crit.yslist_vslug}">
        <SIcon name="bookmarks" />
        <span>{crit.yslist_vname}</span>
        <span>({crit.yslist_count} bộ truyện)</span>
      </a>
    </footer>
  {/if}
</crit-item>

{#if show_repls}
  <YsreplList {replies} bind:_active={show_repls} />
{/if}

<style lang="scss">
  crit-item {
    display: block;
    margin: 1rem 0;
    padding-bottom: 0.01px;

    // @include shadow();
    // @include bgcolor(secd);

    @include bdradi();
    @include linesd(--bd-main, $inset: false);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  header {
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
    @include fgcolor(tert);
    display: inline-flex;
    gap: 0.125rem;
    align-items: center;

    @include bps(font-size, rem(12px), $pl: rem(13px), $tm: rem(14px));

    &._user {
      font-weight: 500;
      @include fgcolor(secd);
      @include clamp($width: null);
      @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
      // flex-shrink: 0;
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

  .version {
    display: flex;
    gap: 0.5rem;
    padding: 0 var(--gutter);
    margin-top: 0.5rem;
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

    // &._loading:after {
    //   display: block;
    //   position: absolute;
    //   content: '';
    //   inset: 0;
    //   @include bgcolor(neutral, 5, 1);
    // }
  }

  .loading {
    @include flex-ca;
    gap: 0.25rem;

    width: 100%;
    height: 10em;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);
    span {
      font-size: 0.9em;
    }
  }

  footer {
    @include flex($gap: 0.375rem);

    @include fgcolor(tert);
    background: inherit;

    // prettier-ignore
    span { @include ftsize(sm); }

    // &._sticky {
    //   position: sticky;
    //   bottom: 0;
    // }
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

  .mute {
    @include fgcolor(secd);
    font-size: em(15, 16);
  }
</style>
