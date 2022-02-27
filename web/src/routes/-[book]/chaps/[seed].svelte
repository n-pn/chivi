<script context="module" lang="ts">
  import { session, page } from '$app/stores'
  import { last_read } from '$utils/ubmemo_utils'

  import { appbar } from '$lib/stores'
  export async function load({ fetch, stuff, url, params }) {
    const { nvinfo, ubmemo } = stuff

    appbar.set({
      left: [
        [nvinfo.vname, 'book', `/-${nvinfo.bslug}`, '_show-lg', '_title'],
        ['Mục lục', 'list', url.pathname, null, '_show-md'],
      ],
      right: gen_appbar_right(nvinfo, ubmemo),
    })

    const sname = params.seed
    const pgidx = +url.searchParams.get('pg') || 1

    const payload = await load_page(fetch, nvinfo, sname, pgidx)
    if (payload.error) return payload

    payload.props.nvinfo = nvinfo
    payload.props.ubmemo = ubmemo
    return payload
  }

  async function load_page(
    fetch: CV.Fetch,
    nvinfo: CV.Nvinfo,
    sname: string,
    pgidx: number,
    force = false
  ) {
    const api_url = `/api/chaps/${nvinfo.id}/${sname}?pg=${pgidx}&force=${force}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    if (payload.error) return payload

    const { chseed } = payload.props
    if (chseed.utime > nvinfo.mftime) nvinfo.mftime = chseed.utime

    return payload
  }

  function gen_appbar_right(nvinfo: CV.Nvinfo, ubmemo: CV.Ubmemo) {
    if (ubmemo.chidx == 0) return null
    const history = last_read(nvinfo, ubmemo)
    const right_opts = { kbd: '+', _text: '_show-lg' }
    return [[history.text, history.icon, history.href, right_opts]]
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import RTime from '$gui/atoms/RTime.svelte'
  import Chlist from '$gui/parts/Chlist.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import SeedList from '../_layout/SeedList.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let ubmemo: CV.Ubmemo = $page.stuff.ubmemo

  export let nvseed: Array<CV.Chseed> = $page.stuff.nvseed
  export let chseed: CV.Chseed
  export let chpage: CV.Chpage

  $: pager = new Pager($page.url, { sname: 'chivi', pg: 1 })

  let _refresh = false
  let _error: string

  async function force_update() {
    _refresh = true
    _error = ''

    // prettier-ignore
    const payload = await load_page(fetch, nvinfo, chseed.sname, chpage.pgidx, true)

    if (payload.props) {
      nvseed = payload.props.nvseed
      chseed = payload.props.chseed
      chpage = payload.props.chpage
    } else {
      _error = payload.error
    }

    _refresh = false
  }
</script>

<chap-page>
  <page-head>
    <SeedList {nvinfo} {nvseed} {chseed} pgidx={chpage.pgidx} />
  </page-head>

  <page-info>
    <info-left>
      <info-text>{chseed.sname}</info-text>
      <info-span>{chpage.total} chương</info-span>
      <info-span><RTime mtime={chseed.utime} /></info-span>
    </info-left>

    <info-right>
      {#if chseed.sname == 'chivi' || chseed.sname == 'users'}
        <a
          class="m-btn"
          class:_disable={$session.privi < 2}
          href="/-{nvinfo.bslug}/+chap?chidx={chpage.total + 1}">
          <SIcon name="circle-plus" />
          <span class="-hide">Thêm</span>
        </a>
      {:else}
        <a
          class="m-btn"
          href={chseed._link}
          target="_blank"
          rel="external noopener noreferer">
          <SIcon name="external-link" />
          <span class="-hide">Nguồn</span>
        </a>
      {/if}

      <button
        class="m-btn _primary umami--click--chaps-force-update"
        disabled={$session.privi < 1}
        on:click={force_update}>
        <SIcon name={_refresh ? 'loader' : 'refresh'} spin={_refresh} />
        <span class="-hide">Đổi mới</span>
      </button>
    </info-right>

    {#if _error}<div class="error">{_error}</div>{/if}
  </page-info>

  <chap-list>
    {#if chpage.pgmax > 0}
      <Chlist
        bslug={nvinfo.bslug}
        sname={chseed.sname}
        chaps={chpage.lasts}
        track={ubmemo}
        is_remote={chseed.stype > 2} />

      <div class="chlist-sep" />

      <Chlist
        bslug={nvinfo.bslug}
        sname={chseed.sname}
        chaps={chpage.chaps}
        track={ubmemo}
        is_remote={chseed.stype > 2} />

      <Footer>
        <div class="foot">
          <Mpager {pager} pgidx={chpage.pgidx} pgmax={chpage.pgmax} />
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
    margin: var(--gutter) 0;

    @include shadow(2);
    @include bgcolor(tert);

    @include bp-min(tm) {
      margin: var(--gutter);
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  page-head {
    display: block;
    @include border(--bd-main, $loc: bottom);
  }

  page-info {
    display: flex;
    padding: 0.75rem 0;

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
