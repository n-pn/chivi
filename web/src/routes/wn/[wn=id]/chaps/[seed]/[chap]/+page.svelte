<script lang="ts">
  import { get_user } from '$lib/stores'
  import { seed_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import MtPage from '$gui/sects/MtPage.svelte'
  import Notext from './Notext.svelte'

  // import Chtabs from './ChapTabs.svelte'

  import { api_call } from '$lib/api_call'
  import { afterNavigate } from '$app/navigation'
  import { recrawl_chap } from './shared'

  import type { PageData } from './$types'
  export let data: PageData
  const _user = get_user()

  $: ({ nvinfo, curr_seed, curr_chap, chap_data } = data)

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

    return { base, list, prev, next }
  }

  afterNavigate(() => {
    update_memo(false)
  })

  async function update_memo(locking: boolean) {
    if ($_user.privi < 0) return

    const { chidx: ch_no, title, uslug } = curr_chap
    const { sname } = curr_seed
    const { cpart } = chap_data

    const path = `/_db/_self/books/${nvinfo.id}/access`
    const body = { sname, ch_no, cpart, title, uslug, locking }

    try {
      data.ubmemo = await api_call(path, body, 'PUT')
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

  async function do_fixraw(line_no: number, orig: string, edit: string) {
    const url = `/_wn/texts/${nvinfo.id}/${curr_seed.sname}/${curr_chap.chidx}`
    const body = { part_no: chap_data.cpart, line_no, orig, edit }

    const res = await fetch(url, {
      method: 'PATCH',
      body: JSON.stringify(body),
      headers: { 'Content-Type': 'application/json' },
    })

    if (res.ok) return null
    return await res.json().then((r) => r.message)
  }

  let _onload = false

  const reload_chap = async (load_mode = 2) => {
    _onload = true
    const json = await recrawl_chap(data, load_mode)
    data = { ...data, ...json }
    _onload = false
  }
</script>

<nav class="bread">
  <a href="/wn/{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.vtitle}</span>
  </a>
  <span>/</span>
  <span class="crumb _text">{curr_chap.chvol}</span>
</nav>

<!-- <Chtabs {nvinfo} {seeds} {nvseed} {chmeta} {chinfo} /> -->

<MtPage
  cvmtl={chap_data.cvmtl}
  ztext={chap_data.ztext}
  mtime={curr_chap.utime}
  wn_id={nvinfo.id}
  {do_fixraw}>
  <svelte:fragment slot="notext">
    <Notext bind:data bind:_onload />
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
          {#if _onload}
            <SIcon name="reload" spin={_onload} />
          {:else}
            <SIcon name={memo_icon} />
          {/if}
          <span>{curr_chap.chidx}/{curr_seed.chmax}</span>
        </button>

        <svelte:fragment slot="content">
          <a
            class="gmenu-item"
            class:_disable={$_user.privi < 1}
            href="{paths.base}/+text?ch_no={curr_chap.chidx}">
            <SIcon name="pencil" />
            <span>Sửa text gốc</span>
          </a>

          <button
            class="gmenu-item"
            disabled={$_user.privi < 1}
            on:click={() => reload_chap(2)}>
            <SIcon name="rotate-rectangle" spin={_onload} />
            <span>Tải lại nguồn</span>
          </button>

          <!-- <button
            class="gmenu-item"
            disabled={$_user.privi < 0}
            on:click={() => retranslate(false)}
            data-kbd="r">
            <SIcon name="rotate-clockwise" />
            <span>Dịch lại</span>
          </button> -->

          {#if on_memory && data.ubmemo.locked}
            <button
              class="gmenu-item"
              disabled={$_user.privi < 0}
              on:click={() => update_memo(false)}
              data-kbd="p">
              <SIcon name="bookmark-off" />
              <span>Bỏ đánh dấu</span>
            </button>
          {:else}
            <button
              class="gmenu-item"
              disabled={$_user.privi < 0}
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
</MtPage>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
