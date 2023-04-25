<script context="module" lang="ts">
  const links = [
    ['mt', 'bolt', 'Dịch máy'],
    ['tl', 'language', 'Dịch tay'],
    ['bv', 'brand-bing', 'Dịch Bing'],
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'
  import { afterNavigate } from '$app/navigation'
  import { seed_path, _pgidx, chap_tail } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Notext from './Notext.svelte'
  import Gmenu from '$gui/molds/Gmenu.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { LayoutData } from './$types'
  import { recrawl_chap } from './shared'
  export let data: LayoutData

  $: ({ nvinfo, curr_seed, wnchap } = data)

  $: paths = gen_paths(data, $page.data.cpart || 1, $page.data.rmode || 'mt')

  function gen_paths(data: LayoutData, cpart: number, rmode: string) {
    const sname = data.curr_seed.sname

    const { ch_no, uslug } = wnchap

    const base = seed_path(nvinfo.bslug, sname)
    const list = seed_path(nvinfo.bslug, sname, _pgidx(wnchap.ch_no))

    const curr = `${base}/${chap_tail(ch_no, cpart, uslug, rmode)}`

    const prev =
      cpart < 2
        ? `${base}/${wnchap._prev}-${rmode}`
        : `${base}/${chap_tail(ch_no, cpart - 1, uslug, rmode)}`

    const next =
      cpart < wnchap.parts.length
        ? `${base}/${chap_tail(ch_no, cpart + 1, uslug, rmode)}`
        : wnchap._next
        ? `${base}/${wnchap._next}-${rmode}`
        : base

    return { base, list, curr, prev, next }
  }

  afterNavigate(() => {
    update_memo(false)
  })

  async function update_memo(locking: boolean) {
    if ($_user.privi < 0) return

    const { ch_no, title, uslug } = wnchap
    const { sname } = curr_seed

    const path = `/_db/_self/books/${nvinfo.id}/access`
    const body = { sname, ch_no, cpart: data.cpart, title, uslug, locking }

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
      on_memory = ubmemo.chidx == wnchap.ch_no && ubmemo.cpart == data.cpart
    }

    if (!ubmemo.locked) return [on_memory, 'menu-2']
    return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
  }

  let _onload = false

  const reload_chap = async () => {
    _onload = true
    const json = await recrawl_chap(data)
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
  <span class="crumb _text">{wnchap.chdiv || 'Chính văn'}</span>
</nav>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a href="{paths.curr}-{href}" class="nav-link">
      <SIcon class="show-ts" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

{#if wnchap.parts.length > 0}
  <slot />
{:else}
  <Notext bind:data />
{/if}

<Footer>
  <div class="navi">
    <a
      href={paths.prev}
      class="m-btn navi-item"
      class:_disable={!wnchap._prev}
      data-key="74"
      data-kbd="←">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <Gmenu class="navi-item" loc="top">
      <button class="m-btn" slot="trigger">
        <SIcon name={_onload ? 'reload' : memo_icon} spin={_onload} />
        <span>{wnchap.ch_no}/{curr_seed.chmax}</span>
      </button>

      <svelte:fragment slot="content">
        <a
          class="gmenu-item"
          class:_disable={$_user.privi < 1}
          href="{paths.base}/+text?ch_no={wnchap.ch_no}">
          <SIcon name="pencil" />
          <span>Sửa text gốc</span>
        </a>

        <button
          class="gmenu-item"
          disabled={$_user.privi < wnchap.privi}
          on:click={reload_chap}>
          <SIcon name="rotate-rectangle" spin={_onload} />
          <span>Tải lại nguồn</span>
        </button>

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
      class:_primary={wnchap._next}
      data-key="75"
      data-kbd="→">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Footer>

<style lang="scss">
  .nav-list {
    margin-bottom: 0.75rem;
  }

  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
