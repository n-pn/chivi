<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'

  import { SIcon, Stars } from '$gui'
  import Truncate from '$gui/atoms/Truncate.svelte'

  import YscritBook from './YscritBook.svelte'

  export let crit: CV.Yscrit
  export let user: CV.Ysuser = { id: 0, uslug: '', uname: '', avatar: '' }
  export let book: CV.Crbook | null = null
  export let list: CV.Yslist | null = null

  export let show_book = true
  export let show_list = true

  export let view_all = false
  export let big_text = false

  let body_type = 'vhtml'

  $: content = crit.vhtml
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

  $: book_path = book ? `/wn/${book.bslug}` : `/wn/${crit.book_id}`
  $: crit_path = `${book_path}/uc/y${crit.id}`
</script>

<section class="crit island">
  <header>
    <a class="m-meta _user" href="/wn/crits?from=ys&user={user.id}"
      >{user.uname}</a>
    <span class="m-meta">&middot;</span>
    <a class="m-meta" href="/sp/qtran/crits/{crit.id}">
      <span>{rel_time(crit.utime)}{crit.utime != crit.ctime ? '*' : ''}</span>
    </a>

    <div class="right">
      <span class="m-meta _star">
        <Stars count={crit.stars} />
      </span>
    </div>
  </header>

  {#if show_book && book}<YscritBook {book} />{/if}

  <div class="vtags">
    {#each crit.vtags as label}
      <a class="vtag" href="/wn/crits?vtag={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <section class="body" class:big_text>
    {#if $_user.privi < 1}
      <p class="u-fg-mute u-fz-sm">
        <em
          >(Bạn cần thiết quyền hạn tối thiểu là 1 để xem bình luận. <a
            href="/hd/faq">Tham khảo lý do</a
          >)</em>
      </p>
    {:else if _onload}
      <div class="loading">
        <SIcon name="loader-2" spin={_onload} />
        <span>Đang tải dữ liệu</span>
      </div>
    {:else}
      <Truncate html={content} bind:view_all />
    {/if}
  </section>

  <footer class="foot" class:_sticky={view_all}>
    <a class="m-meta" href={crit_path}>
      <SIcon name="link" />
      <span>Liên kết</span>
    </a>

    <div class="right">
      <span class="m-meta">
        <SIcon name="thumb-up" />
        <span class="u-show-pl">Ưa thích</span>
        <span class="m-badge">{crit.like_count}</span>
      </span>

      <a class="m-meta" href="{crit_path}#repls">
        <SIcon name="message" />
        <span class="u-show-pl">Phản hồi</span>
        <span class="m-badge">{crit.repl_count}</span>
      </a>
    </div>
  </footer>

  {#if show_list && list}
    <footer class="list">
      <a class="link _list" href="/wn/lists/y{list.id}{list.vslug}">
        <SIcon name="bookmarks" />
        <span>{list.vname}</span>
        <span>({list.book_count} bộ truyện)</span>
      </a>
    </footer>
  {/if}
</section>

<style lang="scss">
  .crit {
    @include margin-y(1rem);

    @include bgcolor(tert);

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

  .m-meta._user {
    font-weight: 500;
    @include fgcolor(secd);
    @include clamp($width: null);
    @include bps(font-size, rem(13px), $pl: rem(14px), $tm: rem(15px));
    // flex-shrink: 0;
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

    --line: 10;
    // prettier-ignore
    @include bp-min(ts) { --line: 8; }
    // prettier-ignore
    @include bp-min(tl) { --line: 6; }
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

  .foot {
    padding: 0.375rem var(--gutter);
  }

  .list {
    padding: 0.25rem var(--gutter);
    @include ftsize(sm);
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
