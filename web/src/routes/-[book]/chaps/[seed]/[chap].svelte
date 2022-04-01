<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'
  import { appbar } from '$lib/stores'
  import { seed_url, to_pgidx } from '$utils/route_utils'

  export async function load({ fetch, params: { seed, chap }, stuff }) {
    const { nvinfo } = stuff
    const [chidx, cpart = 0] = chap.split('-').pop().split('.')

    const book_url = `/-${nvinfo.bslug}`
    const list_url = seed_url(nvinfo.bslug, seed, to_pgidx(chidx))

    appbar.set({
      left: [
        [nvinfo.vname, 'book', book_url, '_title', '_show-sm _title'],
        [`[${seed}]`, null, list_url, null, '_seed'],
      ],
      cvmtl: true,
    })

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
  import CvPage from '$gui/sects/CvPage.svelte'
  import ChapSeed from '../../_layout/ChapSeed.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let ubmemo: CV.Ubmemo = $page.stuff.ubmemo

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  export let zhtext: string[]
  export let cvdata: string

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
    const prev = _prev ? `${base}-${_prev}` : home
    const next = _next ? `${base}-${_next}` : list

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
  <title>{chinfo.title} - {nvinfo.vname} - Chivi</title>
</svelte:head>

<ChapSeed {chmeta} {chinfo} />

{#if cvdata}
  <CvPage
    {cvdata}
    {zhtext}
    dname="-{nvinfo.bhash}"
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

<Footer>
  <div class="navi">
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
          on:click={() => reload_chap(false)}
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
</Footer>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
