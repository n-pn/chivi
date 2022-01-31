<script context="module">
  import { session, navigating, page } from '$app/stores'
  import * as ubmemo_api from '$api/ubmemo_api'

  import { api_call } from '$api/_api_call'
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load({ fetch, stuff, url }) {
    const { nvinfo, ubmemo } = stuff
    const sname = url.searchParams.get('sname') || 'chivi'
    const pgidx = +url.searchParams.get('page')

    const api_url = `chaps/${nvinfo.id}/${sname}?page=${pgidx}`

    const [status, chinfo] = await api_call(fetch, api_url)
    if (status) return { status, error: chinfo }

    if (chinfo.utime > nvinfo.mftime) nvinfo.mftime = chinfo.utime

    appbar.set({
      left: [
        [nvinfo.vname, 'book', `/-${nvinfo.bslug}`, '_title', '_title'],
        ['Mục lục', 'list', url.pathname, null, '_show-md'],
      ],
      right: gen_appbar_right(nvinfo, ubmemo),
    })
    return { props: { chinfo, nvinfo, ubmemo } }
  }

  // function chidx_to_page(chidx, psize = 32) {
  //   if (chidx < 1) return 1
  //   return Math.floor((chidx - 1) / psize) + 1
  // }

  function gen_appbar_right(nvinfo, ubmemo) {
    if (ubmemo.chidx == 0) return null
    const last_read = ubmemo_api.last_read(nvinfo, ubmemo)
    const right_opts = { kbd: '+', _text: '_show-lg' }

    return [[last_read.text, last_read.icon, last_read.href, right_opts]]
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import SeedList from './_layout/SeedList.svelte'
  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let nvinfo = $page.stuff.nvinfo || {}
  export let ubmemo = $page.stuff.ubmemo || {}
  export let chinfo

  $: pager = new Pager($page.url, { sname: 'chivi', page: 1 })
</script>

<SeedList {pager} />

<chap-page>
  <page-info>
    <info-left>
      <info-text>{chinfo.sname}</info-text>
      <info-span>{chinfo.total} chương</info-span>
      <info-span><RTime mtime={chinfo.utime} /></info-span>
    </info-left>

    <info-right>
      {#if chinfo.sname == 'chivi' || chinfo.sname == 'users'}
        <a
          class="m-btn"
          class:_disable={$session.privi < 2}
          href="/-{nvinfo.bslug}/+chap?chidx={chinfo.total + 1}">
          <SIcon name="circle-plus" />
          <span class="-hide">Thêm</span>
        </a>
      {:else}
        <a
          class="m-btn"
          href={chinfo.wlink}
          target="_blank"
          rel="noopener noreferer">
          <SIcon name="external-link" />
          <span class="-hide">Nguồn</span>
        </a>
      {/if}

      <a
        class="m-btn"
        class:_disable={$session.privi < 1}
        href={pager.make_url({ page: chinfo.pgidx, force: true })}>
        {#if $navigating}
          <SIcon name="loader" spin={true} />
        {:else}
          <SIcon name="refresh" />
        {/if}
        <span class="-hide">Đổi mới</span>
      </a>
    </info-right>
  </page-info>

  <chap-list>
    {#if chinfo.pgmax > 0}
      <Chlist
        bslug={nvinfo.bslug}
        sname={chinfo.sname}
        chaps={chinfo.lasts}
        track={ubmemo}
        is_remote={chinfo._type > 2} />

      <div class="chlist-sep" />

      <Chlist
        bslug={nvinfo.bslug}
        sname={chinfo.sname}
        chaps={chinfo.chaps}
        track={ubmemo}
        is_remote={chinfo._type > 2} />

      <footer class="foot">
        <Mpager {pager} pgidx={chinfo.pgidx} pgmax={chinfo.pgmax} />
      </footer>
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
    margin: 0 -0.5rem var(--gutter);

    @include shadow(2);
    @include bgcolor(tert);

    @include bp-min(pl) {
      margin-left: 0;
      margin-right: 0;
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }

    > * {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  page-info {
    display: flex;
    padding-top: var(--gutter);
    padding-bottom: var(--gutter);
    margin-bottom: var(--gutter);

    // @include bgcolor(main);
    // @include bdradi(1rem, $loc: top);
    @include border(--bd-main, $loc: bottom);
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

  .m-btn {
    background: inherit;

    &:hover {
      @include bgcolor(secd);
    }
  }
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
</style>
