<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'
  import { afterNavigate } from '$app/navigation'
  import { config } from '$lib/stores'
  import { init_page } from './_store'
  import { gen_mt_ai_html } from '$lib/mt_data_2'
  import { next_elem, prev_elem } from '$utils/dom_utils'
</script>

<script lang="ts">
  import { type Rdline, Rdword, Rdpage } from '$lib/reader'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Switch from './Switch.svelte'

  import SideLine, { ctrl as lookup_ctrl } from '$gui/parts/SideLine.svelte'
  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'
  import Ctmenu, { ctrl as ctmenu_ctrl } from './qtdata/Ctmenu.svelte'
  import type { SvelteComponent } from 'svelte'

  export let rdata: CV.Chinfo
  export let ropts: CV.Rdopts

  export let p_idx = 0
  let l_idx = -1

  $: pager = new Pager($page.url)

  // states:
  // - 0: no need to reload,
  // - 1: reload, keep focus
  // - 2: reload, clear vtran
  // - 3: reload hviet + vtran
  let state = 3

  let rpage = init_page(rdata.cksum, rdata.ztext || '', p_idx)

  afterNavigate(() => {
    l_idx = -1
    state = 2
    focus_line = undefined
    focus_node = undefined
    $ctmenu_ctrl.actived = false
    rpage = init_page(rdata.cksum, rdata.ztext || '', p_idx)
  })

  $: l_max = rdata.ztext ? rdata.ztext.length : 0

  $: r_mode = $config.r_mode == 1 ? 1 : 2
  $: show_z = $config.show_z

  let reader: HTMLDivElement
  let focus_line: HTMLElement
  let focus_node: HTMLElement

  let ctmenu: SvelteComponent
  $: if (ctmenu) ctmenu.show_menu(reader, focus_node || focus_line)

  let rword = Rdword.from(focus_node)

  $: qkind = ropts.rmode == 'mt' ? ropts.mt_rm : ropts.qt_rm
  $: p_min = rpage.p_min
  $: p_max = rpage.p_idx

  $: vdata = rpage.lines.slice(p_min, p_max)

  let prev_state = 0
  let more_state = 0

  // $: if (more_state == 0 && prev_state == 2) load_prev()
  $: if (more_state == 2) load_more()

  const load_prev = async () => {
    prev_state = 1
    p_idx = await rpage.load_prev(qkind, ropts.pdict, $config._regen)
    prev_state = 0

    p_min = rpage.p_min
    vdata = rpage.load_slice(qkind)
  }

  const load_more = async () => {
    more_state = 1
    p_idx = await rpage.load_more(qkind, ropts.pdict, $config._regen)
    p_max = rpage.p_idx
    more_state = 0
  }

  const handle_click = async (event: MouseEvent) => {
    if ($config.r_mode == 1) return

    let target = event.target as HTMLElement

    while (target != reader) {
      const name = target.nodeName
      if (name == 'CV-DATA') {
        return set_focus_line(+target.dataset.line)
      }

      if (name == 'X-N' || name == 'X-Z') {
        if (target == focus_node) {
          return ctmenu.show_vtform()
        }
        return set_focus_node(target)
      }

      target = target.parentElement
    }
  }

  const on_term_change = async (ztext = '') => {
    if (!ztext) return
    await rpage.reload(ztext, ropts.mt_rm, ropts.pdict, $config._regen || 1)
    vdata = rpage.load_slice(qkind)
  }

  const gen_vdata = (rline: Rdline, mode: number = 1) => {
    if (!rline) return
    const qdata = rline.trans[qkind]
    if (!qdata) return 'Có lỗi dịch, mời liên hệ ban quản trị!'

    if (typeof qdata == 'string') return qdata
    return gen_mt_ai_html(qdata, mode)
  }

  const move_node_left = (evt: Event) => {
    if (!focus_node) return
    const changed = set_focus_node(prev_elem(focus_node) as HTMLElement)
    if (changed) evt.preventDefault()
  }

  const move_node_right = (evt: Event) => {
    if (!focus_node) return
    const changed = set_focus_node(next_elem(focus_node) as HTMLElement)
    if (changed) evt.preventDefault()
  }

  const set_focus_node = (new_node: HTMLElement) => {
    if (!new_node || new_node == focus_node) return false
    rword = Rdword.from(new_node)

    new_node.classList.add('hover')
    if (focus_node) focus_node.classList.remove('hover')
    focus_node = new_node

    while (new_node != reader) {
      new_node = new_node.parentElement
      if (new_node.nodeName == 'CV-DATA') break
    }

    set_focus_line(+new_node.dataset.line, focus_node)
    return true
  }

  function move_line_up() {
    if (l_idx > 0) set_focus_line(l_idx - 1)
  }

  function move_line_down() {
    if (l_idx < l_max) set_focus_line(l_idx + 1)
  }

  const set_focus_line = (new_l_idx: number, new_node?: HTMLElement) => {
    const new_focus = document.getElementById('L' + new_l_idx)
    if (!new_focus || new_focus == focus_line) return

    if (!new_node) {
      new_node = new_focus.querySelector('x-n') as HTMLElement
      if (new_node) new_node.classList.add('hover')

      if (focus_node) focus_node.classList.remove('hover')
      focus_node = new_node
      rword = Rdword.from(new_node)
    }

    l_idx = new_l_idx

    new_focus.classList.add('focus')
    if (focus_line) focus_line.classList.remove('focus')
    focus_line = new_focus

    focus_line.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
  }

  function trigger_on_view(node: HTMLElement) {
    const trigger = ([e]) => {
      if (e.isIntersecting) node.click()
    }
    const observer = new IntersectionObserver(trigger, { threshold: [1] })
    observer.observe(node)
    return { destroy: () => observer.disconnect() }
  }
</script>

<Switch {pager} {ropts} />

{#key rpage}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    class="reader _{$config.r_mode}"
    class:_debug={$config.r_mode == 2}
    style:--textlh="{$config.textlh}%"
    bind:this={reader}
    on:click={handle_click}>
    {#if vdata.length > 0}<Ctmenu bind:this={ctmenu} {rpage} />{/if}

    {#if p_min > 0}
      <div class="d-empty-xs">
        <button class="m-btn _sm" on:click={load_prev}>
          <SIcon name="loader-2" spin={prev_state == 1} />
          <span>Xem {p_min} dòng trước đã đọc</span>
        </button>
      </div>
    {/if}

    {#each vdata as vline, index}
      {@const l_id = p_min + index}
      {@const elem = l_id == 0 ? 'h1' : 'p'}
      <cv-data id="L{l_id}" data-line={l_id}>
        {#if show_z}
          <svelte:element this={elem} class="zdata">{rpage.lines[l_id].ztext}</svelte:element>
        {/if}
        <svelte:element this={elem} class="cdata">{@html gen_vdata(vline, r_mode)}</svelte:element>
      </cv-data>
    {/each}

    {#if rpage.p_idx == 0}
      <div class="d-empty">
        <button class="m-btn _success _sm" use:trigger_on_view on:click={() => (more_state = 2)}>
          <SIcon name="loader-2" spin={more_state == 1} />
          <span>Đang dịch nội dung...</span>
        </button>
      </div>
    {:else if p_max < rpage.p_max}
      <div class="d-empty-xs">
        <button class="m-btn _success _sm" use:trigger_on_view on:click={() => (more_state = 2)}>
          <SIcon name="loader-2" spin={more_state == 1} />
          <span>Xem tiếp {rpage.p_max - p_max} dòng tiếp sau</span>
        </button>
      </div>
    {/if}
  </div>
{/key}

<div hidden>
  <button type="button" data-kbd="esc" on:click={ctmenu_ctrl.hide} />
  <button type="button" data-kbd="←" on:click={move_node_left} />
  <button type="button" data-kbd="→" on:click={move_node_right} />

  <button type="button" data-kbd="↑" on:click={move_line_up} />
  <button type="button" data-kbd="↓" on:click={move_line_down} />
</div>

{#if rpage && $lookup_ctrl.actived}
  <SideLine bind:rpage bind:rword bind:state bind:l_idx {ropts} {l_max} {set_focus_line} />
{/if}

{#if $vtform_ctrl.actived}
  <Vtform rline={rpage.lines[l_idx]} {ropts} {rword} on_close={on_term_change} />
{/if}

<style lang="scss">
  .d-empty {
    :global(svg) {
      font-size: 1.5em;
    }
  }

  .m-flex {
    gap: 0.25rem;
  }

  .reader > :first-child {
    margin-top: 1em;
  }

  .d-empty-xs {
    margin: 1rem 0;
  }
</style>
