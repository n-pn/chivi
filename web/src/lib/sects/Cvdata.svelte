<script context="module">
  import Tlspec, { state as tlspec_state } from '$parts/Tlspec.svelte'
  import Upsert, { state as upsert_state } from '$parts/Upsert.svelte'
  import Lookup, {
    enabled as lookup_enabled,
    activate as lookup_activate,
  } from '$parts/Lookup.svelte'

  import Cvmenu, {
    state as cvmenu_state,
    activate as cvmenu_activate,
    input,
  } from '$parts/Cvmenu.svelte'
</script>

<script>
  import { onMount } from 'svelte'
  import { browser } from '$app/env'
  import { page } from '$app/stores'

  import { ftsize } from '$lib/stores'
  import { MtData } from '$lib/mt_data'
  import read_selection from '$utils/read_selection'

  export let cvdata = ''
  export let zhtext = []

  export let wtitle = true

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'
  export let debug = false

  export let on_change = () => {}

  $: lines = MtData.parse_lines(cvdata)

  let hover_line = 0
  let focus_line = 0
  let focus_word = null

  let article = null

  function on_selection() {
    if (hover_line < 0) return
    const [lower, upper] = read_selection()
    if (upper > 0) $input = [zhtext[hover_line], lower, upper]

    const selection = document.getSelection()
    if (selection.isCollapsed) return

    const range = selection.getRangeAt(0)
    cvmenu_activate(range, article)
  }

  onMount(() => {
    let timeout = null

    const action = document.addEventListener('selectionchange', () => {
      if (timeout) clearTimeout(timeout)
      timeout = setTimeout(on_selection, 200)
    })

    return () => document.removeEventListener('selectionchange', action)
  })

  function handle_click({ target }, index) {
    if (focus_line != index) focus_line = index

    if (target.nodeName == 'C-V') cvmenu_activate(target, article)
    else return cvmenu_state.set(0)

    const lower = +target.dataset.i
    const upper = lower + +target.dataset.l
    $input = [zhtext[index], lower, upper]

    target.classList.add('_focus')

    if (focus_word) focus_word.classList.remove('_focus')
    focus_word = target

    if ($lookup_enabled) lookup_activate($input)
  }

  function render_line(idx = 0, hover = -1, focus = -1, debug = false) {
    // return lines[idx].html
    const mt_data = lines[idx]
    const use_html = idx == hover || idx == focus
    return use_html || debug ? mt_data.html : mt_data.text
  }
</script>

<div hidden>
  <button data-kbd="g" on:click={() => (debug = !debug)}>G</button>
  <button data-kbd="r" on:click={on_change}>R</button>
</div>

<cvdata-wrap bind:this={article}>
  <article class="cvdata _{$ftsize}" class:debug>
    <slot name="header" />
    {#each lines as _, index (index)}
      <div
        id="L{index}"
        class="mtl {wtitle && index == 0 ? '_h' : '_p'}"
        on:click={(e) => handle_click(e, index)}
        on:mouseenter={() => (hover_line = index)}>
        {@html render_line(index, hover_line, focus_line, debug)}
      </div>
    {/each}
  </article>

  {#if browser}
    {#if $upsert_state}
      <Upsert {dname} {d_dub} {on_change} />
    {/if}

    <Lookup {dname} />

    {#if $tlspec_state}
      <Tlspec
        {dname}
        {d_dub}
        ztext={zhtext[hover_line]}
        slink="{$page.path}#L{hover_line}" />
    {/if}

    <Cvmenu />
  {/if}
</cvdata-wrap>

<style lang="scss">
  cvdata-wrap {
    display: block;
    position: relative;
  }
  // .report-line {
  //   display: inline-block;
  //   visibility: hidden;

  //   background: inherit;
  //   padding: 0.25rem;
  //   line-height: 1.25em;
  //   transform: translateY(-0.25rem);

  //   @include ftsize(sm);
  //   @include fgcolor(secd);

  //   :global(svg) {
  //     width: 1.25em;
  //     height: 1.25em;
  //   }

  //   .mtl:hover & {
  //     visibility: visible;
  //     @include fgcolor(harmful, 5);
  //   }
  // }
</style>
