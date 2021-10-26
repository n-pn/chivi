<script context="module">
  import Lookup, {
    activate as lookup_activate,
    enabled as lookup_enabled,
  } from '$parts/Lookup.svelte'

  import Upsert, {
    state as upsert_state,
    activate as upsert_activate,
  } from '$parts/Upsert.svelte'
</script>

<script>
  import { onMount } from 'svelte'
  import { page } from '$app/stores'
  import { session } from '$app/stores'

  import { ftsize } from '$lib/stores'
  import { MtData } from '$lib/mt_data'
  import read_selection from '$utils/read_selection'

  import SIcon from '$atoms/SIcon.svelte'
  import Tlspec, { state as tlspec_state } from '$parts/Tlspec.svelte'

  export let cvdata = ''
  export let zhtext = []

  export let _dirty = false
  export let wtitle = true

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'
  export let debug = false

  export let on_change = () => {}

  $: lines = MtData.parse_lines(cvdata)

  let hover_line = 0
  let focus_line = 0
  let focus_word = null

  let selected = []
  onMount(() => {
    const action = document.addEventListener('selectionchange', () => {
      if (hover_line < 0) return
      const [lower, upper] = read_selection()
      if (upper > 0) selected = [zhtext[hover_line], lower, upper]
    })

    return () => document.removeEventListener('selectionchange', action)
  })

  function handle_click({ target }, index) {
    if (focus_line != index) focus_line = index
    if (target.nodeName != 'C-V') return

    const lower = +target.dataset.i
    const upper = lower + +target.dataset.l
    selected = [zhtext[index], lower, upper]

    if (target === focus_word) {
      upsert_activate(selected, 0)
    } else {
      if (focus_word) focus_word.classList.remove('_focus')
      focus_word = target
      focus_word.classList.add('_focus')
      lookup_activate(selected)
    }
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
  <button data-kbd="r" on:click={() => (_dirty = true)}>R</button>
  <button data-kbd="x" on:click={() => upsert_activate(selected, 0)}>X</button>
  <button data-kbd="c" on:click={() => upsert_activate(selected, 1)}>C</button>
  <button data-kbd="enter" on:click={() => upsert_activate(selected, 0)}
    >E</button>
</div>

<article class="cvdata _{$ftsize}" class:debug>
  <slot name="header" />

  {#each lines as _, index (index)}
    <div
      id="L{index}"
      class="mtl {wtitle && index == 0 ? '_h' : '_p'}"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      {@html render_line(index, hover_line, focus_line, debug)}

      {#if $session.privi >= 0}
        <button
          class="report-line"
          data-tip="Báo lỗi dịch thuật"
          on:click={() => ($tlspec_state = 1)}>
          <SIcon name="flag" />
        </button>
      {/if}
    </div>
  {/each}
</article>

{#if $lookup_enabled}
  <Lookup {dname} />
{/if}

{#if $upsert_state}
  <Upsert {dname} {d_dub} bind:_dirty {on_change} />
{/if}

{#if $tlspec_state}
  <Tlspec
    {dname}
    {d_dub}
    ztext={zhtext[hover_line]}
    slink="{$page.path}#L{hover_line}" />
{/if}

<style lang="scss">
  .report-line {
    display: inline-block;
    visibility: hidden;

    background: inherit;
    padding: 0.25rem;
    line-height: 1.25em;
    transform: translateY(-0.25rem);

    @include ftsize(sm);
    @include fgcolor(secd);

    :global(svg) {
      width: 1.25em;
      height: 1.25em;
    }

    .mtl:hover & {
      visibility: visible;
      @include fgcolor(harmful, 5);
    }
  }
</style>
