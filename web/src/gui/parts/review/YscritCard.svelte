<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'

  import { SIcon, Stars } from '$gui'
  import Truncate from '$gui/atoms/Truncate.svelte'

  import YscritBook from './YscritBook.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'

  export let crit: CV.Yscrit
  export let user: CV.Ysuser
  export let book: CV.Crbook | null = null
  export let list: CV.Yslist | null = null

  export let show_book = true
  export let show_list = true

  export let view_all = crit.vhtml.length < 600
  export let big_text = false

  let show_repls = false

  let body_type = 'vhtml'

  let content = crit.vhtml
  $: swap_content(body_type)

  let cached = {}
  $: cached = { vhtml: crit.vhtml }

  let _onload = false

  async function swap_content(body_type: string) {
    let cached_data = cached[body_type]

    if (cached_data || body_type == 'vhtml') {
      content = cached_data || crit.vhtml
      return
    }

    _onload = true

    const url = `/_ys/crits/${crit.id}/${body_type}`
    const res = await globalThis.fetch(url)
    const res_text = await res.text()
    _onload = false

    if (!res.ok) return alert(res_text)
    cached[body_type] = res_text
    content = res_text
  }

  const body_types: Record<string, [string, number]> = {
    vhtml: ['Dịch thô', -1],
    btran: ['Bing (Việt)', 2],
    deepl: ['DeepL (Eng)', 3],
  }
</script>

<crit-item class="island">
  <header>
    <a class="meta _user" href="/uc?from=ys&user={user.id}">{user.uname}</a>
    <span class="meta">&middot;</span>
    <a class="meta _time" href="/sp/qtran/crits/{crit.id}">
      <span>{rel_time(crit.utime)}{crit.utime != crit.ctime ? '*' : ''}</span>
    </a>

    <div class="right">
      <span class="meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <div class="vtags">
    {#each crit.vtags as label}
      <a class="vtag" href="/uc?vtag={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text>
    {#if _onload}
      <div class="loading">
        <SIcon name="loader-2" spin={_onload} />
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

  <footer class="foot" class:_sticky={view_all}>
    <!-- <span class="meta">&middot;</span> -->

    <a class="meta" href="/uc/y{crit.id}">
      <SIcon name="link" />
      <span>Liên kết</span>
    </a>

    {#if content.length > 600}
      <button class="meta" on:click={() => (view_all = !view_all)}>
        <SIcon name="chevrons-{view_all ? 'up' : 'down'}" />
        <span>{view_all ? 'Thu hẹp' : 'Mở rộng'}</span>
      </button>
    {/if}

    <Gmenu dir="left" loc="bottom">
      <button class="meta" slot="trigger">
        <SIcon name="language" />
        <span>{body_types[body_type][0]}</span>
      </button>
      <svelte:fragment slot="content">
        {#each Object.entries(body_types) as [value, [label, privi]]}
          <button
            class="gmenu-item"
            disabled={$_user.privi < privi}
            on:click={() => (body_type = value)}>
            <span>{label}</span>
          </button>
        {/each}
      </svelte:fragment>
    </Gmenu>

    <div class="right">
      <span class="meta">
        <SIcon name="thumb-up" />
        <span class="u-show-pl">Ưa thích</span>
        <span class="m-badge">{crit.like_count}</span>
      </span>

      <a class="meta" href="/uc/y{crit.id}#repls">
        <SIcon name="message" />
        <span class="u-show-pl">Phản hồi</span>
        <span class="m-badge">{crit.repl_count}</span>
      </a>
    </div>
  </footer>

  {#if show_list && list}
    <footer class="list">
      <a class="link _list" href="/ul/y{list.id}{list.vslug}">
        <SIcon name="bookmarks" />
        <span>{list.vname}</span>
        <span>({list.book_count} bộ truyện)</span>
      </a>
    </footer>
  {/if}
</crit-item>

<style lang="scss">
  crit-item {
    display: block;
    @include margin-y(1rem);
    // padding-bottom: 0.01px;

    // @include shadow();
    @include bgcolor(tert);

    // @include bdradi();
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

  .body {
    padding: 0 var(--gutter);
    position: relative;
    line-height: 1.5em;

    @include bps(font-size, rem(16px), $pl: rem(17px), $tm: rem(18px));

    &.big_text {
      @include bps(font-size, rem(18px), $pl: rem(19px), $tm: rem(20px));
    }

    :global(p) {
      margin-top: 0.5em;
    }

    --line: 12;
    // prettier-ignore
    @include bp-min(ts) { --line: 10; }
    // prettier-ignore
    @include bp-min(ds) { --line: 8; }

    // &._onload:after {
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
  }

  .list {
    @include ftsize(sm);
  }

  .foot {
    padding: 0.375rem var(--gutter);
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
