<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { invalidateAll } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'

  import ChapList from './ChapList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, ubmemo, wstem, chaps, pg_no } = data)

  $: pager = new Pager($page.url, { pg: 1 })

  let _onload = false
  let err_msg: string

  async function reload_chlist(_mode = 1) {
    _onload = true
    err_msg = ''

    const url = `/_rd/wnstems/${wstem.sname}/${nvinfo.id}?crawl=1&regen=1`
    const res = await fetch(url)
    _onload = false

    if (!res.ok) {
      err_msg = await res.text()
    } else {
      await invalidateAll()
    }
  }

  let free_chaps = 0

  $: {
    free_chaps = Math.floor(wstem.chmax / 4)
    if (free_chaps > 120) free_chaps = 120
  }
</script>

<page-info>
  <info-left>
    <info-span>{wstem.chmax} chương</info-span>
    <info-span><RTime mtime={wstem.utime} /></info-span>
  </info-left>

  <info-right>
    <button
      class="m-btn _success"
      class:_fill={wstem.rlink}
      disabled={$_user.privi < 0}
      on:click={() => reload_chlist(2)}
      data-tip="Cập nhật từ nguồn ngoài hoặc dịch lại nội dung"
      data-tip-loc="bottom"
      data-tip-pos="right">
      <SIcon name={_onload ? 'loader-2' : 'refresh'} spin={_onload} />
      <span>Làm mới</span>
    </button>
  </info-right>
</page-info>

{#if err_msg}<div class="chap-hint _error">{err_msg}</div>{/if}

<!-- {#if wstem.rlink}
  <div class="chap-hint" class:_bold={!wstem.fresh}>
    <SIcon name="alert-triangle" />
    Danh sách chương tiết được liên kết tới
    <a class="link" href={wstem.rlink} rel="noreferrer" target="_blank"
      >nguồn ngoài
      <SIcon name="external-link" />
    </a>. Bạn có thể bấm [<SIcon name="refresh" /> Đổi mới] để cập nhật theo nguồn
    ngoài.
  </div>
{/if} -->

{#if wstem.chmax > 0}
  <div class="chap-hint">
    <SIcon name="alert-circle" />
    <span>
      Chương từ <strong class="u-warn">{free_chaps + 1}</strong> cần
      <strong class="u-warn">thanh toán vcoin</strong> để mở khoá.
    </span>
    <span>Hệ số nhân: <strong class="u-warn">{wstem.multp || 3}</strong></span>
  </div>

  <chap-list>
    <ChapList {nvinfo} {ubmemo} {wstem} chaps={data.lasts} />
    <div class="chlist-sep" />
    <ChapList {nvinfo} {ubmemo} {wstem} {chaps} />

    <Footer>
      <div class="foot">
        <Mpager
          {pager}
          pgidx={pg_no}
          pgmax={Math.floor((wstem.chmax - 1) / 32) + 1} />
      </div>
    </Footer>
  </chap-list>
{:else}
  <div class="d-empty">
    <h2>Chưa có text gốc.</h2>
    <p>
      Hãy liên hệ với ban quản trị để khắc phục. Thông tin liên hệ xem cuối
      trang.
    </p>

    <p>
      Nếu bạn có đủ quyền hạn, có thể bấm vào <a
        href="{$page.url.pathname}/up"
        class="m-link">Đăng tải</a> để tự thêm text gốc.
    </p>
  </div>
{/if}

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  page-info {
    display: flex;
    padding: 0.75rem 0;
    @include border(--bd-main, $loc: bottom);

    // @include bgcolor(main);
    // @include bdradi(1rem, $loc: top);
  }

  info-left {
    display: flex;
    flex: 1;
    margin: 0.25rem 0;
    line-height: 1.75rem;
    // transform: translateX(1px);
    @include bps(font-size, 13px, 14px);
  }

  info-right {
    @include flex($gap: 0.5rem);
  }

  .chap-hint {
    // text-align: center;
    // font-style: italic;
    // @include flex-cx($gap: 0.5rem);
    margin: 0.5rem 0;

    @include ftsize(sm);
    @include fgcolor(tert);

    &._error {
      font-size: italic;
      @include fgcolor(harmful, 5);
    }

    :global(svg) {
      display: inline-block;
      margin-bottom: 0.1em;
    }
  }

  info-span {
    font-style: italic;
    @include fgcolor(neutral, 4);

    & + &:before {
      content: '·';
      padding: 0 0.375rem;
    }
  }

  chap-list {
    display: block;
    padding-bottom: 0.75rem;
  }

  .chlist-sep {
    width: 70%;
    margin: var(--gutter) auto;
    @include border(--bd-main, $loc: bottom);
  }

  .foot {
    margin-top: 1rem;
  }
</style>
