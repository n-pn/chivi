<script lang="ts">
  import { seed_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import MtPage2 from '$gui/sects/MtPage2.svelte'
  import Notext from './Notext.svelte'

  // import Chtabs from './ChapTabs.svelte'

  import type { PageData } from './$types'
  import { api_call } from '$lib/api_call'
  import { afterNavigate } from '$app/navigation'
  export let data: PageData

  $: ({ nvinfo, curr_seed, seed_data, curr_chap, chap_data } = data)

  $: paths = gen_paths(
    nvinfo.bslug,
    curr_seed,
    curr_chap.chidx,
    data._prev_url,
    data._next_url
  )

  function gen_paths(
    bslug: string,
    { sname },
    ch_no: number,
    _prev_url: string | null,
    _next_url: string | null
  ) {
    const base = seed_path(bslug, sname)
    const list = seed_path(bslug, sname, _pgidx(ch_no))

    const prev = _prev_url ? `${base}/${_prev_url}` : base
    const next = _next_url ? `${base}/${_next_url}` : list

    return { list, prev, next }
  }

  afterNavigate(() => {
    update_memo(false)
  })

  async function update_memo(locking: boolean) {
    if (data._user.privi < 0) return

    const { chidx: ch_no, title, uslug } = curr_chap
    const { sname } = curr_seed
    const { cpart } = chap_data

    const url = `/_db/_self/books/${nvinfo.id}/access`
    const body = { sname, ch_no, cpart, title, uslug, locking }

    try {
      data.ubmemo = await api_call(url, body, 'PUT')
    } catch (ex) {
      console.log(ex)
    }
  }

  $: [on_memory, memo_icon] = check_memo(data.ubmemo)

  function check_memo(ubmemo: CV.Ubmemo): [boolean, string] {
    let on_memory = false
    if (ubmemo.sname == curr_seed.sname) {
      on_memory =
        ubmemo.chidx == curr_chap.chidx && ubmemo.cpart == chap_data.cpart
    }

    if (!ubmemo.locked) return [on_memory, 'menu-2']
    return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
  }

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
  <a href="/wn/{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <span class="crumb _text">{curr_chap.chvol}</span>
</nav>

<!-- <Chtabs {nvinfo} {seeds} {nvseed} {chmeta} {chinfo} /> -->

<MtPage2
  cvmtl={chap_data.cvmtl}
  ztext={chap_data.ztext}
  mtime={curr_chap.utime}
  wn_id={nvinfo.id}
  {on_fixraw}>
  <svelte:fragment slot="notext">
    <Notext
      book_info={nvinfo}
      {curr_seed}
      {seed_data}
      {curr_chap}
      {chap_data} />
  </svelte:fragment>

  <Footer slot="footer">
    <div class="navi">
      <a
        href={paths.prev}
        class="m-btn navi-item"
        class:_disable={!data._prev_url}
        data-key="74"
        data-kbd="←">
        <SIcon name="chevron-left" />
        <span>Trước</span>
      </a>

      <Gmenu class="navi-item" loc="top">
        <button class="m-btn" slot="trigger">
          <SIcon name={memo_icon} />
          <span>{curr_chap.chidx}/{curr_seed.chmax}</span>
        </button>

        <svelte:fragment slot="content">
          <a
            class="gmenu-item"
            class:_disable={data._user.privi < 1}
            href="{seed_path(
              nvinfo.bslug,
              curr_seed.sname
            )}/{curr_chap.chidx}/+edit">
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

          {#if on_memory && data.ubmemo.locked}
            <button
              class="gmenu-item"
              disabled={data._user.privi < 0}
              on:click={() => update_memo(false)}
              data-kbd="p">
              <SIcon name="bookmark-off" />
              <span>Bỏ đánh dấu</span>
            </button>
          {:else}
            <button
              class="gmenu-item"
              disabled={data._user.privi < 0}
              on:click={() => update_memo(true)}
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
        class:_primary={data._next_url}
        data-key="75"
        data-kbd="→">
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
