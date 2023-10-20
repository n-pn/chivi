<script context="module" lang="ts">
  import { Rdpage, Rdword } from '$lib/reader'
  const rpages = new Map<string, Rdpage>()
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { afterNavigate } from '$app/navigation'

  import Lookup2, { ctrl as lookup_ctrl } from '$gui/parts/Lookup2.svelte'
  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

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
  let focus_line: HTMLElement

  // states:
  // - 0: no need to reload,
  // - 1: reload, keep focus
  // - 2: reload, clear vtran
  // - 3: reload hviet + vtran

  let state = 3

  afterNavigate(() => {
    l_idx = -1
    state = 2
  })

  let l_idx = -1
  $: l_max = rdata.ztext ? rdata.ztext.length : 0

  $: rpage = init_page(rdata.fpath, rdata.ztext || [], ropts)
  let rword = new Rdword()

  function init_page(fpath: string, ztext: string[], ropts: CV.Rdopts) {
    let rpage = rpages.get(fpath)
    if (!fpath) return rpage

    if (!rpage) {
      rpage = new Rdpage(ztext, ropts)
      rpages.set(fpath, rpage)
    } else {
      if (rpage.ropts.mt_rm != ropts.mt_rm) {
        rpage.state.mt_ai = 0
      }
      rpage.ropts = ropts
      // TODO: invalidate mt_ai data if algorithm changed
    }

    return rpage
  }

  const handle_mouse = async (
    event: MouseEvent,
    panel: string = 'overview'
  ) => {
    if ($config.r_mode == 1) return
    let click_on_node = false

    let target = event.target as HTMLElement
    if (target.nodeName == 'X-N') {
      rword = Rdword.from(target)
      click_on_node = panel == 'overview'
    }

    while (target != reader) {
      if (target.classList.contains('cdata')) break
      else target = target.parentElement
    }

    if (target == reader) return

    event.preventDefault()
    const l_idx = +target.dataset.line
    change_focus(l_idx, click_on_node ? 'upsert' : panel)
  }

  const change_focus = async (new_l_idx: number, panel = '') => {
    l_idx = new_l_idx

    const new_focus = document.getElementById('L' + l_idx)
    if (new_focus != focus_line) {
      if (focus_line) focus_line.classList.remove('focus')
      focus_line = new_focus
      focus_line.classList.add('focus')
    }

    focus_line.scrollIntoView({ block: 'nearest', behavior: 'smooth' })

    if (panel == 'upsert') {
      await rpage.load_hviet(1)
      vtform_ctrl.show()
    } else {
      await rpage.reload({ hviet: 1, qt_v1: 1, mt_ai: 1, bt_zv: 1 })
      lookup_ctrl.show(panel)
    }
  }

  const tabs = [
    { type: 'qt', href: '?rm=qt', icon: 'language', text: 'Dịch thô' },
    { type: 'mt', href: '?rm=mt', icon: 'bolt', text: 'Dịch máy ✨' },
    // { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    // { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]

  const on_term_change = async (changed = false) => {
    if (!changed) return
    rpage = await rpage.load_mt_ai(2, false)
  }
</script>

<Section {tabs} _now={ropts.rmode}>
  <Switch {pager} {ropts} />

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    class="reader _{$config.r_mode}"
    style:--textlh="{$config.textlh}%"
    bind:this={reader}
    on:click={(e) => handle_mouse(e, 'overview')}
    on:contextmenu={(e) => handle_mouse(e, 'glossary')}>
    {#if rdata.error == 414}
      <Notext {cstem} bind:rdata bind:state />
    {:else if rdata.error == 413 || rdata.error == 415}
      <Unlock {cstem} bind:rdata bind:state />
    {:else if ropts.rmode == 'qt' || ropts.rmode == 'mt'}
      <Qtpage {rpage} {label} bind:state />
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
    on:click={() => change_focus(l_idx - 1)} />
  <button
    type="button"
    data-kbd="↓"
    disabled={l_idx == l_max}
    on:click={() => change_focus(l_idx + 1)} />
</div>

{#if rpage && $lookup_ctrl.actived}
  <Lookup2 bind:rpage bind:rword bind:state bind:l_idx {l_max} {change_focus} />
{/if}

{#if $vtform_ctrl.actived}
  <Vtform
    rline={rpage.lines[l_idx]}
    {rword}
    {ropts}
    on_close={on_term_change} />
{/if}

<style lang="scss">
  .reader {
    @include border(--bd-soft, $loc: top);

    // @include border(--bd-soft, $loc: top);
  }
</style>
