<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'
  import { api_get, api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import MtPage2 from '$gui/sects/MtPage2.svelte'
  import Notext from '$gui/parts/Notext.svelte'

  // import Chtabs from './ChapTabs.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, seeds, _curr, _chap, ztext } = data)
  $: paths = gen_paths(data)

  $: _seed = _curr._seed

  function gen_paths({
    nvinfo: { bslug },
    _curr: { _seed },
    _chap,
    _next,
    _prev,
  }) {
    const home = `/wn/${bslug}`
    const base = seed_base_url(bslug, _seed.sname, _seed.s_bid)

    const list = base + '?pg=' + Math.floor((_chap.ch_no - 1) / 32) + 1

    const prev = _prev ? `${base}/${_prev}` : home
    const next = _next ? `${base}/${_next}` : list

    return { list, prev, next }
  }

  function seed_base_url(bslug: string, sname: string, s_bid: number) {
    const base = `/wn/${bslug}/chaps/${sname}`
    return sname[0] == '!' ? `${base}:${s_bid}` : base
  }

  // async function update_history(lock: boolean) {
  //   const { sname, cpart } = chmeta
  //   const { chidx, title, uslug } = chinfo

  //   const url = `/_db/_self/books/${nvinfo.id}/access`
  //   const body = { sname, cpart, chidx, title, uslug, locked: lock }

  //   try {
  //     await api_call(url, body, 'PUT')

  //     // $page.data.ubmemo = res
  //   } catch (ex) {
  //     alert(ex.body.message)
  //   }
  // }

  // $: [on_memory, memo_icon] = check_memo($page.data.ubmemo)

  // function check_memo(ubmemo: CV.Ubmemo): [boolean, string] {
  //   let on_memory = false
  //   if (ubmemo.sname == chmeta.sname) {
  //     on_memory = ubmemo.chidx == chinfo.chidx && ubmemo.cpart == chmeta.cpart
  //   }

  //   if (!ubmemo.locked) return [on_memory, 'menu-2']
  //   return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
  // }

  async function on_fixraw(line_no: number, orig: string, edit: string) {
    // const url = `/_db/texts/${nvinfo.id}/${nvseed.sname}/${chinfo.chidx}`
    // const body = { part_no: chmeta.cpart, line_no, orig, edit }
    // const res = await fetch(url, {
    //   method: 'PATCH',
    //   body: JSON.stringify(body),
    //   headers: { 'Content-Type': 'application/json' },
    // })
    // if (!res.ok) alert(await res.json().then((r) => r.message))
  }
</script>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <span class="crumb _text">{_chap.chvol}</span>
</nav>

<!-- <Chtabs {nvinfo} {seeds} {nvseed} {chmeta} {chinfo} /> -->

<MtPage2 {ztext} mtime={_chap.utime} wn_id={nvinfo.id} {on_fixraw}>
  <svelte:fragment slot="notext">
    <!-- <Notext {nvseed} {chmeta} {chinfo} /> -->
  </svelte:fragment>

  <Footer slot="footer">
    <div class="navi">
      <a
        href={paths.prev}
        class="m-btn navi-item"
        class:_disable={!data._prev}
        data-kbd="j">
        <SIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <Gmenu class="navi-item" loc="top">
        <!-- <button class="m-btn" slot="trigger">
          <SIcon name={memo_icon} />
          <span>{chinfo.chidx}/{chmeta.total}</span>
        </button> -->

        <svelte:fragment slot="content">
          <a
            class="gmenu-item"
            class:_disable={$session.privi < 1}
            href="/-{nvinfo.bslug}/chaps/{_seed.sname}/{_chap.chidx}/+edit">
            <SIcon name="pencil" />
            <span>Sửa text gốc</span>
          </a>

          <!-- <button
            class="gmenu-item"
            disabled={$session.privi < 1}
            on:click={reload_chap}>
            <SIcon name="rotate-rectangle" spin={_reloading} />
            <span>Tải lại nguồn</span>
          </button> -->

          <!-- <button
            class="gmenu-item"
            disabled={$session.privi < 0}
            on:click={() => retranslate(false)}
            data-kbd="r">
            <SIcon name="rotate-clockwise" />
            <span>Dịch lại</span>
          </button> -->

          <!-- {#if on_memory && $page.data.ubmemo.locked}
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
          {/if} -->

          <a href={paths.list} class="gmenu-item" data-kbd="h">
            <SIcon name="list" />
            <span>Mục lục</span>
          </a>
        </svelte:fragment>
      </Gmenu>

      <a
        href={paths.next}
        class="m-btn _fill navi-item"
        class:_primary={data._next}
        data-kbd="k">
        <span>Kế tiếp</span>
        <SIcon name="chevron-right" />
      </a>
    </div>
  </Footer>
</MtPage2>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
