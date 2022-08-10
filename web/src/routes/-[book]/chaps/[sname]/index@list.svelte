<script context="module" lang="ts">
  import { getContext } from 'svelte'
  import type { Writable } from 'svelte/store'

  import { session, page } from '$app/stores'

  export async function load({ stuff, url, params: { sname } }) {
    const { api, nvinfo } = stuff

    const pgidx = +url.searchParams.get('pg') || 1
    const chlist = await api.chlist(nvinfo.id, sname, pgidx)
    if (chlist.error) return chlist

    const props = Object.assign(stuff, { chlist })

    return { props }
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Chlist from '$gui/parts/Chlist.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import { rel_time } from '$utils/time_utils'
  import { invalidate } from '$app/navigation'
  import Gmenu from '$gui/molds/Gmenu.svelte'

  export let nvinfo: CV.Nvinfo

  let ubmemo: Writable<CV.Ubmemo> = getContext('ubmemos')

  export let nvseed: CV.Chroot
  export let chlist: CV.Chlist

  $: pager = new Pager($page.url, { pg: 1 })

  let _refresh = false
  let _error: string

  async function reload_source() {
    _refresh = true
    _error = ''

    $page.stuff.api.uncache('nvinfos', nvinfo.bslug)
    $page.stuff.api.uncache('nslists', nvinfo.id)

    const res = await $page.stuff.api.nvseed(nvinfo.id, nvseed.sname, 1)
    _refresh = false

    if (res.error) {
      _error = res.error
    } else {
      invalidate($page.url.toString())
    }
  }

  function internal_seed(sname: string) {
    return sname.match(/^=|@|users/)
  }

  function can_edit(sname: string) {
    if (sname.startsWith('=')) return $session.privi > 1
    if (!sname.startsWith('@')) return $session.privi > 2
    if (sname != '@' + $session.uname) return false
    return $session.privi > 0
  }
</script>

<article class="article">
  <page-info>
    <info-left>
      <info-text>{nvseed.sname}</info-text>
      <info-span>{nvseed.chmax} chương</info-span>
      <info-span><RTime mtime={nvseed.utime} /></info-span>
    </info-left>

    <info-right>
      {#if nvseed.stype == 0 && can_edit(nvseed.sname)}
        <a
          class="m-btn _primary _fill"
          class:_disable={$session.privi < 1}
          href="/-{nvinfo.bslug}/chaps/{nvseed.sname}/+chap?chidx={nvseed.chmax +
            1}"
          data-tip="Yêu cầu quyền hạn: 1">
          <SIcon name="upload" />
          <span class="-hide">Thêm chương</span>
        </a>
      {:else}
        <button
          class="m-btn _primary umami--click--chaps-force-update"
          disabled={$session.privi < 0}
          data-tip="Yêu cầu quyền hạn: Đăng nhập"
          on:click={reload_source}>
          <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
          <span class="-hide">Cập nhật</span>
        </button>
      {/if}

      <Gmenu dir="right" let:trigger>
        <button class="m-btn" slot="trigger" on:click={trigger}>
          <SIcon name="menu-2" />
          <span class="-hide">Nâng cao</span>
        </button>

        <svelte:fragment slot="content">
          {#if nvseed.stype == 0 && can_edit(nvseed.sname)}
            <button
              class="gmenu-item umami--click--chaps-force-update"
              disabled={$session.privi < 0}
              on:click={reload_source}>
              <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
              <span class="-hide">Đổi mới</span>
            </button>
          {:else}
            <a
              class="gmenu-item"
              href={nvseed.slink}
              target="_blank"
              rel="external noopener noreferer">
              <SIcon name="external-link" />
              <span>Liên kết</span>
            </a>
          {/if}

          <a
            class="gmenu-item"
            class:_disable={$session.privi < 1}
            href="/-{nvinfo.bslug}/chaps/{nvseed.sname}/+edit">
            <SIcon name="settings" />
            <span>Cài đặt</span>
          </a>
        </svelte:fragment>
      </Gmenu>
    </info-right>
  </page-info>

  {#if _error}<div class="error">{_error}</div>{/if}
  <div class="chap-hint">
    <span>Gợi ý:</span>
    <span class="-hint" class:_bold={!nvseed.fresh}
      >Bấm "<SIcon name="refresh" /> Đổi mới" để cập nhật danh sách chương tiết.</span>
    <span class="-stat"
      >Lần cập nhật cuối: <strong>{rel_time(nvseed.stime)}</strong>.</span>
  </div>

  <chap-list>
    {#if chlist.pgmax > 0}
      <Chlist {nvinfo} {nvseed} ubmemo={$ubmemo} chlist={nvseed.lasts} />
      <div class="chlist-sep" />
      <Chlist {nvinfo} {nvseed} ubmemo={$ubmemo} chlist={chlist.chaps} />

      <Footer>
        <div class="foot">
          <Mpager {pager} pgidx={chlist.pgidx} pgmax={chlist.pgmax} />
        </div>
      </Footer>
    {:else}
      <p class="empty">Không có nội dung :(</p>
    {/if}
  </chap-list>
</article>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .article {
    @include padding-y(0);
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

  .-hide {
    @include bps(display, none, $tm: inline-block);
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

    .-hint._bold {
      @include fgcolor(warning, 5);
    }

    :global(svg) {
      display: inline-block;
      margin-bottom: 0.1em;
    }
  }

  // .m-btn {
  //   background: inherit;

  //   &:hover {
  //     @include bgcolor(secd);
  //   }
  // }
  // .chinfo {
  //   margin-bottom: var(--gutter-pl);
  // }

  info-text {
    padding-left: 0.5rem;
    @include label();
    @include fgcolor(tert);
    @include border(primary, 5, $width: 3px, $loc: left);
  }

  info-span {
    font-style: italic;
    @include fgcolor(neutral, 4);

    &:before {
      display: inline-block;
      content: '·';
      text-align: center;
      @include bps(width, 0.5rem, 0.75rem, 1rem);
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

  .empty {
    min-height: 30vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(neutral, 5);
  }

  .foot {
    margin-top: 1rem;
  }

  .error {
    font-size: italic;
    @include fgcolor(harmful, 5);
    @include ftsize(sm);
  }
</style>
