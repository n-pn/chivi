<script context="module">
  import { call_api } from '$api/_api_call'

  export async function load({ fetch, params: { seed, chap }, stuff }) {
    const { nvinfo } = stuff
    const [chidx, cpart = 0] = chap.split('-').pop().split('.')

    const url = `chaps/${nvinfo.id}/${seed}/${chidx}/${+cpart}`
    const [status, cvchap] = await call_api(fetch, url, null, 'GET')

    if (status) return { status, error: cvchap }
    return { props: { ...stuff, ...cvchap } }
  }
</script>

<script>
  import { session } from '$app/stores'
  import { invalidate } from '$app/navigation'

  import SIcon from '$atoms/SIcon.svelte'
  import Gmenu from '$molds/Gmenu.svelte'
  import Notext from '$parts/Notext.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'
  import CvPage from '$sects/CvPage.svelte'
  import ChapSeed from '../_layout/ChapSeed.svelte'

  export let nvinfo
  export let ubmemo
  export let chseed

  export let chmeta
  export let chinfo

  export let zhtext
  export let cvdata

  const on_change = () => reload_chap(false)

  $: paths = gen_paths(nvinfo, chmeta, chinfo)
  $: api_url = gen_api_url(nvinfo, chmeta, chinfo)

  function gen_api_url({ id: book_id }, { sname, cpart }, { chidx }) {
    return `/api/chaps/${book_id}/${sname}/${chidx}/${cpart}`
  }

  async function reload_chap(redo = false) {
    if ($session.privi < 1) return
    // console.log({ api_url })

    if (redo) {
      const res = await fetch(api_url + '?redo=true')
      if (!res.ok) return console.log('Error: ' + (await res.text()))
      const data = await res.json()
      ubmemo = data.ubmemo
      chmeta = data.chmeta
      chinfo = data.chinfo
      zhtext = data.zhtext
      cvdata = data.cvdata
    } else {
      const res = await fetch(api_url + '/text')
      if (res.ok) cvdata = await res.text()
      else console.log(res.status)
    }
  }

  function gen_paths({ bslug }, { sname, _prev, _next }, { chidx }) {
    const home = gen_book_path(bslug, sname, 0)
    const list = gen_book_path(bslug, sname, chidx)

    const base = `/-${bslug}/-${sname}/`
    const prev = _prev ? `${base}-${_prev}` : home
    const next = _next ? `${base}-${_next}` : list

    return { home, list, prev, next }
  }

  function gen_book_path(bslug, sname, chidx) {
    let url = `/-${bslug}/-${sname}`
    const page = Math.floor((chidx - 1) / 32) + 1
    return page > 1 ? url + `?page=${page}` : url
  }

  async function update_history(lock) {
    const { sname, cpart } = chmeta
    const { chidx, title, uslug } = chinfo

    const url = `_self/books/${nvinfo.id}/access`
    const params = { sname, cpart, chidx, title, uslug, locked: lock }

    const [status, payload] = await call_api(fetch, url, params, 'PUT')
    if (status) return console.log(`Error update history: ${payload}`)

    ubmemo = payload
    invalidate(`/api/books/${nvinfo.bslug}`)
  }

  $: on_memory = check_memo(ubmemo)
  // prettier-ignore
  $: memo_icon = !ubmemo.locked ? 'menu-2' : on_memory ? 'bookmark' : 'bookmark-off'

  function check_memo(ubmemo) {
    if (ubmemo.sname != chmeta.sname) return false
    return ubmemo.chidx == chinfo.chidx && ubmemo.cpart == chmeta.cpart
  }
</script>

<svelte:head>
  <title>{chinfo.title} - {nvinfo.vname} - Chivi</title>
</svelte:head>

<Appbar ptype="cvmtl">
  <svelte:fragment slot="left">
    <a href={paths.home} class="header-item _title">
      <SIcon name="book" />
      <span class="header-text _show-sm _title">{nvinfo.hname}</span>
    </a>

    <button class="header-item _active">
      <span class="header-text _seed">[{chmeta.sname}]</span>
    </button>
  </svelte:fragment>
</Appbar>

<Vessel>
  <ChapSeed {nvinfo} {chseed} {chmeta} {chinfo} />

  {#if cvdata}
    <CvPage
      {cvdata}
      {zhtext}
      dname={nvinfo.bhash}
      d_dub={nvinfo.vname}
      {on_change}>
      <svelte:fragment slot="header">
        <nav class="bread">
          <a href="/-{nvinfo.bslug}" class="crumb _link">{nvinfo.vname}</a>
          <span>/</span>
          <span class="crumb _text">{chinfo.chvol}</span>
        </nav>
      </svelte:fragment>
    </CvPage>
  {:else}
    <Notext {chmeta} />
  {/if}

  <div class="navi" slot="footer">
    <a
      href={paths.prev}
      class="m-btn navi-item"
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
          class="-item"
          disabled={$session.privi < 1}
          on:click={reload_chap}
          data-kbd="r">
          <SIcon name="rotate-clockwise" />
          <span>Dịch lại</span>
        </button>

        {#if $session.privi > 1}
          {#if chmeta.clink != '/'}
            <button class="-item" on:click={() => reload_chap(true)}>
              <SIcon name="rotate-rectangle" />
              <span>Tải lại nguồn</span>
            </button>
          {:else}
            <a
              class="-item"
              href="/-{nvinfo.bslug}/+chap?chidx={chinfo.chidx}&mode=edit">
              <SIcon name="pencil" />
              <span>Sửa text gốc</span>
            </a>
          {/if}
        {/if}

        {#if on_memory && ubmemo.locked}
          <button
            class="-item"
            disabled={$session.privi < 0}
            on:click={() => update_history(false)}
            data-kbd="p">
            <SIcon name="bookmark-off" />
            <span>Bỏ đánh dấu</span>
          </button>
        {:else}
          <button
            class="-item"
            disabled={$session.privi < 0}
            on:click={() => update_history(true)}
            data-kbd="p">
            <SIcon name="bookmark" />
            <span>Đánh dấu</span>
          </button>
        {/if}

        <a href={paths.list} class="-item" data-kbd="h">
          <SIcon name="list" />
          <span>Mục lục</span>
        </a>
      </svelte:fragment>
    </Gmenu>

    <a
      href={paths.next}
      class="m-btn _fill navi-item"
      class:_primary={chmeta._next}
      data-kbd="k">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Vessel>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
