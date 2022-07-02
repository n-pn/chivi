<script context="module" lang="ts">
  import { nvinfo_bar } from '$utils/topbar_utils'
  import { seed_url, to_pgidx } from '$utils/route_utils'

  import { get, type Writable } from 'svelte/store'
  import { config } from '$lib/stores'

  export async function load({ params, stuff }) {
    const { api, nvinfo, ubmemo, nslist } = stuff
    const { sname, chidx, cpart: slug } = params
    const cpart = +slug.split('/')[1] || 1

    const api_url = gen_api_url(nvinfo, sname, chidx, cpart - 1)
    const api_res = await api.call(api_url)
    if (api_res.error) return api_res

    const topbar = gen_topbar(nvinfo, sname, chidx)
    const props = Object.assign(api_res, { nvinfo, nslist })

    props.redirect = slug == ''
    return { props, stuff: { topbar } }
  }

  function gen_topbar(nvinfo: CV.Nvinfo, sname: string, chidx: number) {
    const list_url = seed_url(nvinfo.bslug, sname, to_pgidx(chidx))

    return {
      left: [
        nvinfo_bar(nvinfo, { show: 'pl' }),
        [sname, 'list', { href: list_url, kind: 'zseed' }],
      ],
      right: [],
      config: true,
    }
  }

  function gen_api_url(
    { id: book },
    sname: string,
    chidx: number,
    cpart = 0,
    redo = false
  ) {
    let api_url = `/api/chaps/${book}/${sname}/${chidx}/${cpart}?redo=${redo}`
    if (get(config).tosimp) api_url += '&trad=true'
    return api_url
  }
</script>

<script lang="ts">
  import { getContext } from 'svelte'
  import { page, session } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Notext from '$gui/parts/Notext.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import CvPage from '$gui/sects/MtPage.svelte'
  import Chtabs from './_tabs.svelte'

  export let nvinfo: CV.Nvinfo
  export let nslist: CV.Nvseed[]
  export let chmemo: CV.Ubmemo

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  export let cvdata: string
  export let zhtext: string[]
  export let rl_key: string

  export let min_privi = -1
  export let chidx_max = 0

  let ubmemo: Writable<CV.Ubmemo> = getContext('ubmemos')
  $: ubmemo.set(chmemo)

  $: paths = gen_paths(nvinfo, chmeta, chinfo)

  $: if ($$props.redirect) {
    const path = $page.url.pathname
    const url = path.replace(new RegExp(`${chinfo.chidx}$`), chmeta._curr)
    globalThis.history?.replaceState({ chmeta }, null, url)
  }

  let _reloading = false
  async function reload_chap() {
    if ($session.privi < 1) return
    _reloading = true

    const { sname, cpart } = chmeta
    const url = gen_api_url(nvinfo, sname, chinfo.chidx, cpart, true)
    const res = await $page.stuff.api.call(url)

    if (res.error) return alert(`Error: ${res.error}`)

    cvdata = res.cvdata
    chmeta = res.chmeta
    chinfo = res.chinfo
    $ubmemo = res.chmemo
    _reloading = false
  }

  async function retranslate() {
    const base = $config.engine == 2 ? '/_v2/qtran/chaps' : '/api/qtran/chaps'

    const url = `${base}/${rl_key}?trad=${$config.tosimp}&user=${$session.uname}`
    const res = await fetch(url)
    const txt = await res.text()

    if (res.ok) cvdata = txt
    else alert(res)
  }

  function gen_paths({ bslug }, { sname, _prev, _next }, { chidx }) {
    const home = seed_url(bslug, sname, 1)
    const list = seed_url(bslug, sname, to_pgidx(chidx))

    const base = `/-${bslug}/chaps/${sname}/`
    const prev = _prev ? `${base}${_prev}` : home
    const next = _next ? `${base}${_next}` : list

    return { list, prev, next }
  }

  async function update_history(lock: boolean) {
    const { sname, cpart } = chmeta
    const { chidx, title, uslug } = chinfo

    const url = `/api/_self/books/${nvinfo.id}/access`
    const body = { sname, cpart, chidx, title, uslug, locked: lock }

    const res = await $page.stuff.api.call(url, 'PUT', body)

    if (res.error) alert(res.error)
    else $ubmemo = res
  }

  $: [on_memory, memo_icon] = check_memo($ubmemo)

  function check_memo(ubmemo: CV.Ubmemo) {
    let on_memory = false
    if (ubmemo.sname == chmeta.sname) {
      on_memory = ubmemo.chidx == chinfo.chidx && ubmemo.cpart == chmeta.cpart
    }

    if (!ubmemo.locked) return [on_memory, 'menu-2']
    return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
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

<CvPage {cvdata} {zhtext} on_change={retranslate}>
  <svelte:fragment slot="header">
    <Chtabs {nvinfo} {nslist} {chmeta} {chinfo} />
  </svelte:fragment>

  <svelte:fragment slot="notext">
    <Notext {chmeta} {min_privi} {chidx_max} />
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
          <a
            class="gmenu-item"
            class:_disable={$session.privi < 1}
            href="/-{nvinfo.bslug}/chaps/{chmeta.sname}/{chinfo.chidx}/+edit">
            <SIcon name="pencil" />
            <span>Sửa text gốc</span>
          </a>

          <button
            class="gmenu-item umami--click--reload-rmtext"
            disabled={$session.privi < 0}
            on:click={reload_chap}>
            <SIcon name="rotate-rectangle" spin={_reloading} />
            <span>Tải lại nguồn</span>
          </button>

          <button
            class="gmenu-item umami--click-reconvert-chap"
            disabled={$session.privi < 0}
            on:click={retranslate}
            data-kbd="r">
            <SIcon name="rotate-clockwise" />
            <span>Dịch lại</span>
          </button>

          {#if on_memory && $ubmemo.locked}
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
