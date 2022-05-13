<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'
  import { topbar } from '$lib/stores'
  import { seed_url, to_pgidx } from '$utils/route_utils'

  export async function load({ fetch, params: { seed, chap }, stuff }) {
    const { nvinfo } = stuff
    const [chidx, cpart = 0] = chap.split('-')[0].split('.')

    const api_url = `/api/chaps/${nvinfo.id}/${seed}/${chidx}/${+cpart}`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }
</script>

<script lang="ts">
  import { page, session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Notext from '$gui/parts/Notext.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import CvPage from '$gui/sects/MtPage.svelte'
  import ChapSeed from '../_layout/ChapSeed.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let ubmemo: CV.Ubmemo = $page.stuff.ubmemo

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  export let zhtext: string[]
  export let cvdata: string

  export let min_privi = -1
  export let chidx_max = 0

  const on_change = () => reload_chap(false)

  $: paths = gen_paths(nvinfo, chmeta, chinfo)
  $: api_url = gen_api_url(nvinfo, chmeta, chinfo)

  $: book_url = `/-${nvinfo.bslug}`
  $: list_url = seed_url(nvinfo.bslug, ubmemo.sname, to_pgidx(chinfo.chidx))

  $: globalThis.history?.replaceState({ chmeta }, null, chmeta._curr)

  $: topbar.set({
    left: [
      [nvinfo.btitle_vi, 'book', { href: book_url, kind: 'title', show: 'pl' }],
      [`[${ubmemo.sname}]`, null, { href: list_url, kind: 'zseed' }],
    ],
    right: [],
    config: true,
  })

  function gen_api_url({ id: book_id }, { sname, cpart }, { chidx }) {
    return `/api/chaps/${book_id}/${sname}/${chidx}/${cpart}`
  }

  async function reload_chap(redo = false) {
    if ($session.privi < 1) return
    // console.log({ api_url })

    if (redo) {
      const res = await fetch(api_url + '?redo=true')
      if (!res.ok) return console.log('Error: ' + (await res.text()))
      const { props } = await res.json()
      ubmemo = props.ubmemo
      chmeta = props.chmeta
      chinfo = props.chinfo
      zhtext = props.zhtext
      cvdata = props.cvdata
    } else {
      const res = await fetch(api_url + '/text?redo=true')
      if (res.ok) cvdata = await res.text()
      else console.log(res.status)
    }
  }

  function gen_paths({ bslug }, { sname, _prev, _next }, { chidx }) {
    const home = seed_url(bslug, sname, 1)
    const list = seed_url(bslug, sname, to_pgidx(chidx))

    const base = `/-${bslug}/-${sname}/`
    const prev = _prev ? `${base}${_prev}` : home
    const next = _next ? `${base}${_next}` : list

    return { list, prev, next }
  }

  async function update_history(lock: boolean) {
    const { sname, cpart } = chmeta
    const { chidx, title, uslug } = chinfo

    const url = `_self/books/${nvinfo.id}/access`
    const params = { sname, cpart, chidx, title, uslug, locked: lock }

    const [status, payload] = await api_call(fetch, url, params, 'PUT')
    if (status) return console.log(`Error update history: ${payload}`)

    ubmemo = payload
    invalidate(`/api/books/${nvinfo.bslug}`)
  }

  $: on_memory = check_memo(ubmemo)
  // prettier-ignore
  $: memo_icon = !ubmemo.locked ? 'menu-2' : on_memory ? 'bookmark' : 'bookmark-off'

  function check_memo(ubmemo: CV.Ubmemo) {
    if (ubmemo.sname != chmeta.sname) return false
    return ubmemo.chidx == chinfo.chidx && ubmemo.cpart == chmeta.cpart
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <span class="crumb _text">{chinfo.chvol}</span>
</nav>

<CvPage
  {cvdata}
  {zhtext}
  dname="-{nvinfo.bhash}"
  d_dub={nvinfo.btitle_vi}
  {on_change}>
  <svelte:fragment slot="header">
    <ChapSeed {chmeta} {chinfo} />
  </svelte:fragment>
  <svelte:fragment slot="notext">
    {#if !cvdata}
      <Notext {chmeta} {min_privi} {chidx_max} />
    {/if}
  </svelte:fragment>

  <Footer slot="footer">
    <div class="navi">
      <a
        href={paths.prev}
        class="m-btn navi-item umami--click--prev-chap"
        class:_disable={!chmeta._prev}
        data-kbd="j">
        <SIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <Gmenu class="navi-item" loc="top">
        <div class="m-btn" slot="trigger">
          <SIcon name={memo_icon} />
          <span>{chinfo.chidx}/{chmeta.total}</span>
        </div>

        <svelte:fragment slot="content">
          <button
            class="gmenu-item umami--click-reconvert-chap"
            disabled={$session.privi < 1}
            on:click={() => reload_chap(false)}
            data-kbd="r">
            <SIcon name="rotate-clockwise" />
            <span>Dịch lại</span>
          </button>

          {#if $session.privi > 1}
            {#if chmeta.clink != '/'}
              <button
                class="gmenu-item umami--click--reload-rmtext"
                on:click={() => reload_chap(true)}>
                <SIcon name="rotate-rectangle" />
                <span>Tải lại nguồn</span>
              </button>
            {:else}
              <a
                class="gmenu-item"
                href="/-{nvinfo.bslug}/+chap?chidx={chinfo.chidx}&mode=edit">
                <SIcon name="pencil" />
                <span>Sửa text gốc</span>
              </a>
            {/if}
          {/if}

          {#if on_memory && ubmemo.locked}
            <button
              class="gmenu-item"
              disabled={$session.privi < 0}
              on:click={() => update_history(false)}
              data-kbd="p">
              <SIcon name="bookmark-off" />
              <span>Bỏ đánh dấu</span>
            </button>
          {:else}
            <button
              class="gmenu-item umami--click--bookmark"
              disabled={$session.privi < 0}
              on:click={() => update_history(true)}
              data-kbd="p">
              <SIcon name="bookmark" />
              <span>Đánh dấu</span>
            </button>
          {/if}

          <a href={paths.list} class="gmenu-item" data-kbd="h">
            <SIcon name="list" />
            <span>Mục lục</span>
          </a>
        </svelte:fragment>
      </Gmenu>

      <a
        href={paths.next}
        class="m-btn _fill navi-item umami--click--next-chap"
        class:_primary={chmeta._next}
        data-kbd="k">
        <span>Kế tiếp</span>
        <SIcon name="chevron-right" />
      </a>
    </div>
  </Footer>
</CvPage>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
