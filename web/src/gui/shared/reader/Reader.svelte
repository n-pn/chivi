<script context="module" lang="ts">
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

  let ztext = []
  let hviet = []

  let l_max = 0

  $: if (browser && ropts.fpath) load_zdata(ropts)

  async function load_zdata(ropts: CV.Rdopts) {
    const data = await call_hviet_file(ropts)
    hviet = data.hviet
    ztext = data.ztext || []
    l_max = hviet.length
  }

  afterNavigate(async () => {
    if (focused_node) focused_node.classList.remove('focus')
    l_idx = -1
    state = 1
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
      <Notext {cstem} {rdata} />
    {:else if rdata.error == 413}
      <Unlock {cstem} {rdata} />
    {:else if ropts.rtype == 'qt' || ropts.rtype == 'mt'}
      <Qtpage {ztext} {hviet} {ropts} {label} bind:state />
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