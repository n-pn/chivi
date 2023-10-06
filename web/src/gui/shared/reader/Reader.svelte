<script context="module" lang="ts">
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { afterNavigate } from '$app/navigation'

  import Lookup2 from '$gui/parts/Lookup2.svelte'

  import { ctrl as lookup_ctrl } from '$lib/stores/lookup_stores'

  import { browser } from '$app/environment'
  import { config } from '$lib/stores'

  import Section from '$gui/sects/Section.svelte'

  import Switch from './Switch.svelte'
  import Notext from './Notext.svelte'
  import Unlock from './Unlock.svelte'
  import Qtpage from './Qtpage.svelte'

  export let rstem: CV.Rdstem
  export let ropts: CV.Rdopts
  export let rdata: CV.Chpart

  $: pager = new Pager($page.url, { rm: 'qt', qt: 'qt_v1', mt: 'mtl_1' })
  $: label = rdata.p_max > 1 ? `[${rdata.p_idx}/${rdata.p_max}]` : ''

  let reader: HTMLDivElement
  let focused_node: HTMLElement

  const handle_mouse = (event: MouseEvent, panel: string = 'overview') => {
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

  let l_idx = -1
  let state = 0 // states: 0: fresh, 1: blank, 2: stale

  $: l_max = rdata.ztext.length

  afterNavigate(() => {
    l_idx = -1
    state = 1
    if (focused_node) focused_node.classList.remove('focus')
  })

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

<Section {tabs} _now={ropts.rtype}>
  <Switch {pager} {ropts} />

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    class="reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
    bind:this={reader}
    on:click|capture={(e) => handle_mouse(e, 'overview')}
    on:contextmenu|capture={(e) => handle_mouse(e, 'glossary')}>
    {#if rdata.error == 414}
      <Notext {rstem} {rdata} />
    {:else if rdata.error == 413}
      <Unlock {rstem} {rdata} />
    {:else if ropts.rtype == 'qt' || ropts.rtype == 'mt'}
      <Qtpage ztext={rdata.ztext} {ropts} {label} bind:state />
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
