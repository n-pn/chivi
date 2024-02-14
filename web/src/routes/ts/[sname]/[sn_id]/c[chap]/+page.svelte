<script lang="ts">
  import { afterNavigate } from '$app/navigation'
  import { mark_rdchap } from '$lib/common/rdmemo'

  import { chap_path, _pgidx } from '$lib/kit_path'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Footer from '$gui/sects/Footer.svelte'
  import Reader from '$gui/shared/reader/Reader.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crepo, rdata, ropts, rmemo } = data)

  $: ch_no = rdata.ch_no
  $: pg_no = _pgidx(ch_no)

  $: base_path = `/ts/${crepo.sroot}`
  $: memo_path = pg_no < 2 ? base_path : base_path + '?pg=' + pg_no

  $: prev_path = ch_no > 1 ? chap_path(base_path, ch_no - 1, ropts) : base_path
  $: next_path = ch_no < crepo.chmax ? chap_path(base_path, ch_no + 1, ropts) : memo_path

  afterNavigate(async () => await save_chmemo())

  const main_menu_icon = ({ ch_no }, { lc_mtype, lc_ch_no }) => {
    if (ch_no == lc_ch_no) return ['list', 'bookmark', 'pin'][lc_mtype]
    return ['list', 'bookmark-off', 'pinned-off'][lc_mtype]
  }

  const save_chmemo = async (mtype = -1) => {
    $rmemo = await mark_rdchap($rmemo, rdata, ropts, mtype)
  }

  let _onload = false

  const reseed_chap = async () => {
    _onload = true

    const url = `/_rd/chaps/${crepo.sroot}/${rdata.ch_no}?regen=true`
    const res = await fetch(url, { cache: 'no-cache' })

    _onload = false

    if (res.ok) {
      rdata = await res.json()
      window.location.reload()
    } else {
      alert(await res.text())
    }
  }

  const mark_types = [
    ['eye', 'Đánh dấu theo chương đọc mới nhất'],
    ['bookmark', 'Đánh dấu đọc chương tuần tự'],
    ['pinned', 'Đánh dấu đọc chương cố định'],
  ]
</script>

<Reader {crepo} {ropts} {rdata} />

<Footer>
  <div class="navi">
    <a href={prev_path} class="m-btn _primary navi-item" class:_disable={ch_no < 2} data-kbd="⌃←">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <Gmenu class="navi-item" loc="top">
      <button class="m-btn" slot="trigger" data-kbd="m">
        <SIcon name={_onload ? 'reload' : main_menu_icon(rdata, $rmemo)} />
        <span>{ch_no} / {crepo.chmax}</span>
      </button>

      <svelte:fragment slot="content">
        <a href={memo_path} class="gmenu-item" data-kbd="h">
          <SIcon name="list" />
          <span>Về mục lục</span>
        </a>

        <a
          class="gmenu-item"
          class:_disable={$_user.privi < 0}
          href="{base_path}/+text?ch_no={ch_no}">
          <SIcon name="pencil" />
          <span>Sửa text gốc</span>
          <SIcon class="u-right" name="privi-0" iset="icons" />
        </a>

        {#if rdata.rlink}
          <button class="gmenu-item" disabled={$_user.privi < 0} on:click={reseed_chap}>
            <SIcon name="rotate-rectangle" spin={_onload} />
            <span>Tải lại nguồn</span>
            <SIcon class="u-right" name="privi-0" iset="icons" />
          </button>
        {/if}

        <div class="gmenu-item marks">
          {#each mark_types as [icon, hint], mtype}
            <button
              class="mchap"
              class:_active={ch_no == $rmemo.lc_ch_no && mtype == $rmemo.lc_mtype}
              disabled={$_user.privi < 0}
              data-tip={hint}
              on:click={() => save_chmemo(mtype)}>
              <SIcon name={icon} />
            </button>
          {/each}

          {#if ch_no != $rmemo.lc_ch_no}
            <a
              class="mchap"
              href={chap_path(base_path, $rmemo.lc_ch_no, $rmemo)}
              data-tip="Nhảy tới trang đã đánh dấu">
              <SIcon name="external-link" />
            </a>
          {:else}
            <span class="mchap u-fg-mute" data-tip="Nhảy tới trang đã đánh dấu">
              <SIcon name="external-link" />
            </span>
          {/if}
        </div>
      </svelte:fragment>
    </Gmenu>

    <a
      href={next_path}
      class="m-btn _fill navi-item"
      class:_primary={ch_no <= crepo.chmax}
      data-key="75"
      data-kbd="⌃→">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Footer>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }

  .marks {
    @include flex;
  }

  .mchap {
    background: inherit;
    flex: 1;

    @include fgcolor(tert);

    &._active {
      @include fgcolor(primary, 5);
    }
  }
</style>
