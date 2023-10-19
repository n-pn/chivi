<script context="module" lang="ts">
  import { Rdpage, Rdword } from '$lib/reader'
  const rdpages = new Map<string, Rdpage>()
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { afterNavigate } from '$app/navigation'

  import Lookup2, { ctrl as lookup_ctrl } from '$gui/parts/Lookup2.svelte'
  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

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

  // states:
  // - 0: no need to reload,
  // - 1: reload, keep focus
  // - 2: reload, clear vtran
  // - 3: reload hviet + vtran

  let state = 3
  let l_idx = -1
  let l_max = 0

  afterNavigate(() => {
    l_idx = -1
  })

  $: l_max = rdata.ztext.length

  $: rdpage = init_page(rdata, ropts)
  let rdword = new Rdword(undefined)

  function init_page(rdata: CV.Chpart, ropts: CV.Rdopts) {
    let rdpage = rdpages.get(rdata.fpath)

    if (!rdpage) {
      rdpage = new Rdpage(rdata.ztext, ropts)
      rdpages.set(rdata.fpath, rdpage)
    } else {
      if (rdpage.ropts.mt_rm != ropts.mt_rm) {
        rdpage.state.mt_ai = 0
      }
      rdpage.ropts = ropts
      // TODO: invalidate mt_ai data if algorithm changed
    }

    return rdpage
  }

  const handle_mouse = (event: MouseEvent, panel: string = 'overview') => {
    if ($config.r_mode == 1) return
    $lookup_ctrl.panel = panel

    let target = event.target as HTMLElement
    if (target.nodeName == 'X-N') rdword = new Rdword(target)

    while (target != reader) {
      if (target.classList.contains('cdata')) break
      target = target.parentElement
    }

    if (target == reader) return
    event.preventDefault()

    l_idx = +target.dataset.line
  }

  $: if (browser && l_idx >= 0) {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != focused_node) {
      if (focused_node) focused_node.classList.remove('focus')
      focused_node = new_focus
      focused_node.classList.add('focus')
      focused_node.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    console.log(new_focus)
    active_lookup_panel()
  }

  const active_lookup_panel = async () => {
    rdpage = await rdpage.reload({ qt_v1: 1, mt_ai: 1, bt_zv: 1 })
    lookup_ctrl.show('')
  }

  const tabs = [
    { type: 'qt', href: '?rm=qt', icon: 'bolt', text: 'Dịch thô' },
    { type: 'mt', href: '?rm=mt', icon: 'language', text: 'Dịch máy' },
    // { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    // { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]

  const on_term_change = (term?: CV.Viterm) => {
    console.log({ term })
    // todo
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
    on:click|capture={(e) => handle_mouse(e, 'overview')}
    on:contextmenu|capture={(e) => handle_mouse(e, 'glossary')}>
    {#if rdata.error == 414}
      <Notext {cstem} bind:rdata bind:state />
    {:else if rdata.error == 413 || rdata.error == 415}
      <Unlock {cstem} bind:rdata bind:state />
    {:else if ropts.rmode == 'qt' || ropts.rmode == 'mt'}
      <Qtpage {rdpage} {label} />
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

{#if rdpage && $lookup_ctrl.actived}
  <Lookup2 bind:rdpage bind:rdword bind:state bind:l_idx {l_max} />
{/if}

<!-- {#if $vtform_ctrl.actived}
  <Vtform bind:rdline={rdpage[l_idx]} on_close={on_term_change} />
{/if} -->

<style lang="scss">
  .reader {
    @include border(--bd-soft, $loc: top);

    // @include border(--bd-soft, $loc: top);
  }
</style>
