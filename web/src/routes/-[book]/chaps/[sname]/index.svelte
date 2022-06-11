<script context="module" lang="ts">
  import { session, page } from '$app/stores'

  export async function load({ fetch, stuff, url, params: { sname } }) {
    const { nvinfo } = stuff

    const pg = +url.searchParams.get('pg') || 1
    const api_url = gen_api_url(nvinfo, sname, `/${pg}`)
    const api_res = await fetch(api_url)

    const chlist = await api_res.json()
    return { props: Object.assign(stuff, { chlist }) }
  }

  function gen_api_url({ bslug }, sname: string, tail = '') {
    return `/api/seeds/${bslug}/${sname}${tail}`
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Chlist from '$gui/parts/Chlist.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import SeedTabs from '../_tabs.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import { rel_time } from '$utils/time_utils'
  import { invalidate } from '$app/navigation'

  export let nvinfo: CV.Nvinfo
  export let ubmemo: CV.Ubmemo

  export let nslist: CV.Nvseed[]
  export let nvseed: CV.Nvseed
  export let chlist: CV.Chlist

  $: pager = new Pager($page.url, { sname: 'union', pg: 1 })

  let _refresh = false
  let _error: string

  async function refresh_seed() {
    _refresh = true
    _error = ''

    const api_url = gen_api_url(nvinfo, nvseed.sname, '?force=true')
    const api_res = await fetch(api_url)

    if (api_res.ok) {
      await api_res.json()
      invalidate(`/api/seeds/${nvinfo.bslug}`)
      // invalidate(`/api/${nvinfo.bslug}`)
    } else {
      _error = await api_res.text()
    }

    _refresh = false
  }

  function internal_seed(sname: string) {
    return sname.match(/^$|@|users|union/)
  }
</script>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span class="-text">{nvinfo.btitle_vi}</span></a>
  <span>/</span>
  <span class="crumb _text">Chương tiết</span>
</nav>

<SeedTabs {nvinfo} {nslist} cur_sname={nvseed.sname} cur_pgidx={chlist.pgidx} />

<chap-page>
  <page-info>
    <info-left>
      <info-text>{nvseed.sname}</info-text>
      <info-span>{nvseed.chaps} chương</info-span>
      <info-span><RTime mtime={nvseed.utime} /></info-span>
    </info-left>

    <info-right>
      <button
        class="m-btn _primary umami--click--chaps-force-update"
        disabled={$session.privi < 1}
        data-tip="Yêu cầu quyền hạn: Đăng nhập"
        on:click={refresh_seed}>
        <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
        <span class="-hide">Đổi mới</span>
      </button>

      {#if internal_seed(nvseed.sname)}
        <a
          class="m-btn"
          class:_disable={$session.privi < 2}
          href="/-{nvinfo.bslug}/chaps/+chap?chidx={nvseed.chaps + 1}"
          data-tip="Yêu cầu quyền hạn: 2">
          <SIcon name={$session.privi < 2 ? 'lock' : 'circle-plus'} />
          <span class="-hide">Thêm chương</span>
        </a>
      {:else}
        <a
          class="m-btn"
          href={nvseed.slink}
          target="_blank"
          rel="external noopener noreferer">
          <SIcon name="external-link" />
          <span class="-hide">Liên kết ngoài</span>
        </a>
      {/if}
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
      <Chlist
        bslug={nvinfo.bslug}
        sname={nvseed.sname}
        total={nvseed.chaps}
        chaps={nvseed.lasts}
        track={ubmemo}
        privi={$session.privi}
        stype={nvseed.stype} />

      <div class="chlist-sep" />

      <Chlist
        bslug={nvinfo.bslug}
        sname={nvseed.sname}
        total={nvseed.chaps}
        chaps={chlist.chaps}
        track={ubmemo}
        privi={$session.privi}
        stype={nvseed.stype} />

      <Footer>
        <div class="foot">
          <Mpager {pager} pgidx={chlist.pgidx} pgmax={chlist.pgmax} />
        </div>
      </Footer>
    {:else}
      <p class="empty">Không có nội dung :(</p>
    {/if}
  </chap-list>
</chap-page>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  chap-page {
    display: block;
    margin: 0;
    margin-bottom: var(--gutter);
    @include padding-x(var(--gutter));

    @include shadow(2);
    @include bgcolor(tert);

    @include bp-min(tm) {
      @include margin-x(var(--gutter));
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
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
    transform: translateX(1px);
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
