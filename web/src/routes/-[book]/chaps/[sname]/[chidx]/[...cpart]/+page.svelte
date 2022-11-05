<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'
  import { api_get, api_put, api_call } from '$lib/api'
  import { gen_api_url, gen_retran_url } from './shared'
  import { seed_url, to_pgidx } from '$utils/route_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Notext from '$gui/parts/Notext.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import MtPage from '$gui/sects/MtPage.svelte'

  import Chtabs from '../ChapTabs.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, nslist, nvseed, chmeta, chinfo, cvdata, rl_key } = data)
  $: paths = gen_paths(nvinfo, chmeta, chinfo)

  $: if ($$props.redirect) {
    const path = $page.url.pathname
    const url = path.replace(new RegExp(`${chinfo.chidx}$`), chmeta._curr)
    globalThis.history?.replaceState({ chmeta }, null, url)
  }

  let _reloading = false
  async function reload_chap() {
    _reloading = true

    const { sname, cpart } = chmeta
    const url = gen_api_url(nvinfo, sname, chinfo.chidx, cpart, true)
    const res = await api_get(url, null, fetch)

    if (res.error) return alert(`Error: ${res.error}`)

    cvdata = res.cvdata
    chmeta = res.chmeta
    chinfo = res.chinfo
    // $page.data.ubmemo = res.chmemo
    _reloading = false
  }

  async function retranslate(reload = false) {
    const url = gen_retran_url(rl_key, $session.uname, reload)

    const res = await fetch(url)
    const txt = await res.text()

    if (res.ok) cvdata = txt
    else alert(txt)
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

    const res = await api_put(url, body, fetch)

    if (res.error) alert(res.error)
    // else $page.data.ubmemo = res
  }

  $: [on_memory, memo_icon] = check_memo($page.data.ubmemo)

  function check_memo(ubmemo: CV.Ubmemo): [boolean, string] {
    let on_memory = false
    if (ubmemo.sname == chmeta.sname) {
      on_memory = ubmemo.chidx == chinfo.chidx && ubmemo.cpart == chmeta.cpart
    }

    if (!ubmemo.locked) return [on_memory, 'menu-2']
    return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
  }

  async function on_fixraw(line_no: number, orig: string, edit: string) {
    const url = `/api/texts/${nvinfo.id}/${nvseed.sname}/${chinfo.chidx}`
    const params = { part_no: chmeta.cpart, line_no, orig, edit }
    const res = await api_call(url, 'PATCH', params, fetch)

    if (res.error) {
      alert(res.error)
    } else {
      rl_key = res.trim()
      retranslate(true)
    }
  }
</script>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <span class="crumb _text">{chinfo.chvol}</span>
</nav>

<Chtabs {nvinfo} {nslist} {nvseed} {chmeta} {chinfo} />

<MtPage
  {cvdata}
  mftime={chinfo.utime}
  source={chmeta.clink}
  on_change={() => retranslate(false)}
  {on_fixraw}>
  <svelte:fragment slot="notext">
    <Notext {nvseed} {chmeta} {chinfo} />
  </svelte:fragment>

  <Footer slot="footer">
    <div class="navi">
      <a
        href={paths.prev}
        class="m-btn navi-item"
        class:_disable={!chmeta._prev}
        data-kbd="j">
        <SIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <Gmenu class="navi-item" loc="top" let:trigger>
        <button class="m-btn" slot="trigger" on:click={trigger}>
          <SIcon name={memo_icon} />
          <span>{chinfo.chidx}/{chmeta.total}</span>
        </button>

        <svelte:fragment slot="content">
          <a
            class="gmenu-item"
            class:_disable={$session.privi < 1}
            href="/-{nvinfo.bslug}/chaps/{chmeta.sname}/{chinfo.chidx}/+edit">
            <SIcon name="pencil" />
            <span>Sửa text gốc</span>
          </a>

          <button
            class="gmenu-item"
            disabled={$session.privi < 1}
            on:click={reload_chap}>
            <SIcon name="rotate-rectangle" spin={_reloading} />
            <span>Tải lại nguồn</span>
          </button>

          <button
            class="gmenu-item"
            disabled={$session.privi < 0}
            on:click={() => retranslate(false)}
            data-kbd="r">
            <SIcon name="rotate-clockwise" />
            <span>Dịch lại</span>
          </button>

          {#if on_memory && $page.data.ubmemo.locked}
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
              class="gmenu-item"
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
        class="m-btn _fill navi-item"
        class:_primary={chmeta._next}
        data-kbd="k">
        <span>Kế tiếp</span>
        <SIcon name="chevron-right" />
      </a>
    </div>
  </Footer>
</MtPage>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
