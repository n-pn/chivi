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
  // import { session } from '$app/stores'
  import { split_mtdata } from '$lib/mt_data'
  import read_selection from '$utils/read_selection'

  export let cvdata = ''
  export let zhtext = []

  export let _dirty = false
  export let wtitle = true

  export let dname = 'various'
  export let label = 'Tổng hợp'

  let debug = true

  $: lines = split_mtdata(cvdata)

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

  function render_line(idx, hover, focus) {
    const mt_data = lines[idx]
    const use_html = idx == hover || idx == focus
    return use_html || debug ? mt_data.html : mt_data.text
  }
</script>

<div hidden>
  <button data-kbd="r" on:click={() => (_dirty = true)}>R</button>
  <button data-kbd="x" on:click={() => upsert_activate(selected, 0)}>X</button>
  <button data-kbd="c" on:click={() => upsert_activate(selected, 1)}>C</button>
  <button data-kbd="enter" on:click={() => upsert_activate(selected, 0)}
    >E</button>
</div>

<article class="cvdata">
  {#each lines as _, index (index)}
    <div
      class="mtl {wtitle && index == 0 ? '_h' : '_p'}"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      {@html render_line(index, hover_line, focus_line)}
    </div>
  {/each}
</article>

{#if $lookup_enabled}
  <Lookup {dname} />
{/if}

{#if $upsert_state}
  <Upsert {dname} {label} bind:_dirty />
{/if}
