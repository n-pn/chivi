<script context="module" lang="ts">
  import { data as lookup_data } from '$lib/stores/lookup_stores'
  import {
    call_bt_zv_text,
    call_qt_v1_file,
    call_mt_ai_file,
  } from '$utils/tran_util'
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { afterNavigate } from '$app/navigation'
  import { call_hviet_file } from '$utils/tran_util'

  import Lookup2 from '$gui/parts/Lookup2.svelte'

  import { ctrl as lookup_ctrl } from '$lib/stores/lookup_stores'

  import { browser } from '$app/environment'
  import { config } from '$lib/stores'

  import Section from '$gui/sects/Section.svelte'

  import Switch from './Switch.svelte'
  import Notext from './Notext.svelte'
  import Unlock from './Unlock.svelte'
  import Qtpage from './Qtpage.svelte'

  export let cstem: CV.Chstem
  export let rdata: CV.Chpart
  export let ropts: CV.Rdopts

  $: pager = new Pager($page.url, { rm: 'qt', qt: 'qt_v1', mt: 'mtl_1' })
  $: label = rdata.p_max > 1 ? `[${rdata.p_idx}/${rdata.p_max}]` : ''

  // $: ropts.fpath = rdata.fpath

  let reader: HTMLDivElement
  let focused_node: HTMLElement

  const handle_mouse = (event: MouseEvent, panel: string = 'overview') => {
    if ($config.r_mode == 1) return

    let target = event.target as HTMLElement

    while (target != reader) {
      if (target.classList.contains('cdata')) break
      target = target.parentElement
    }

    if (target == reader) return

    event.preventDefault()

    l_idx = +target.dataset.line
    lookup_ctrl.show(panel)
  }

  // states:
  // - 0: no need to reload,
  // - 1: reload, keep focus
  // - 2: reload, clear vtran
  // - 3: reload hviet + vtran

  let state = 3

  let ztext = []
  let hviet = []
  let vtran: CV.Qtdata | CV.Mtdata = { lines: [], mtime: 0, tspan: 0 }

  let l_idx = -1
  let l_max = 0

  afterNavigate(async () => {
    if (focused_node) focused_node.classList.remove('focus')
    state = $lookup_data.ropts.fpath == rdata.fpath ? 2 : 3
    l_idx = -1
  })

  $: if (browser && state > 0 && rdata.fpath) {
    if (state > 2) ztext = hviet = []
    if (state > 1) vtran = { lines: [], mtime: 0, tspan: 0 }

    state = 0
    ropts.fpath = rdata.fpath
    if (ropts.fpath) load_data(ropts)
  }

  async function load_data(ropts: CV.Rdopts) {
    if (hviet.length == 0) {
      const data = await call_hviet_file(ropts)

      hviet = data.hviet
      ztext = data.ztext || []
      l_max = hviet.length
    }

    const finit = { ...ropts, force: true }
    const rinit = { cache: 'default' } as RequestInit

    let rname = ropts.qt_rm

    if (ropts.rmode == 'mt' || rname == 'mt_ai') {
      vtran = await call_mt_ai_file(finit, rinit, fetch)
      rname = 'mt_ai'
    } else if (rname == 'bt_zv') {
      vtran = await call_bt_zv_text(ztext, finit, rinit, fetch)
    } else if (rname == 'qt_v1') {
      vtran = await call_qt_v1_file(finit, rinit, fetch)
    }

    if (vtran.error) return
    lookup_data.put({ ropts, ztext, hviet, [rname]: vtran.lines })
  }

  $: if (browser && l_idx >= 0) {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != focused_node) {
      if (focused_node) focused_node.classList.remove('focus')
      focused_node = new_focus
      focused_node.classList.add('focus')
      focused_node.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    lookup_ctrl.show()
  }

  const tabs = [
    { type: 'qt', href: '?rm=qt', icon: 'bolt', text: 'Dịch thô' },
    { type: 'mt', href: '?rm=mt', icon: 'language', text: 'Dịch máy' },
    // { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    // { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]
</script>

<Section {tabs} _now={ropts.rmode}>
  <Switch {pager} {ropts} />

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    class="reader _{$config.r_mode}"
    style:--textlh="{$config.textlh}%"
    bind:this={reader}
    on:click|capture={(e) => handle_mouse(e, 'overview')}
    on:contextmenu|capture={(e) => handle_mouse(e, 'glossary')}>
    {#if rdata.error == 414}
      <Notext {cstem} bind:rdata bind:state />
    {:else if rdata.error == 413 || rdata.error == 415}
      <Unlock {cstem} bind:rdata bind:state />
    {:else if ropts.rmode == 'qt' || ropts.rmode == 'mt'}
      <Qtpage {ztext} {vtran} {label} />
    {:else}
      Chưa hoàn thiện!
    {/if}
  </div>
</Section>

<div hidden>
  <button
    type="button"
    data-kbd="↑"
    disabled={l_idx == 0}
    on:click={() => (l_idx -= 1)} />
  <button
    type="button"
    data-kbd="↓"
    on:click={() => (l_idx += 1)}
    disabled={l_idx == l_max} />
</div>

<Lookup2 bind:state {ropts} bind:l_idx {l_max} />

<style lang="scss">
  .reader {
    @include border(--bd-soft, $loc: top);

    // @include border(--bd-soft, $loc: top);
  }
</style>
