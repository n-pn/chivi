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
  import { session } from '$app/stores'

  import { split_mtdata } from '$lib/mt_data'

  import Aditem, { ad_indexes } from '$molds/Aditem.svelte'

  export let cvdata = ''
  export let _dirty = false
  export let wtitle = true

  export let dname = 'various'
  export let label = 'Tổng hợp'

  $: lines = split_mtdata(cvdata)
  $: adidx = ad_indexes(lines.length)

  let hover_line = -1
  let focus_line = -1
  let focus_word = null

  import read_selection from '$utils/read_selection'

  let upsert_input = []
  onMount(() => {
    const action = document.addEventListener('selectionchange', () => {
      const phrase = read_selection()
      if (phrase) upsert_input = phrase
    })

    return () => document.removeEventListener('selectionchange', action)
  })

  function handle_click({ target }, index) {
    if (focus_line != index) focus_line = index
    if (target.nodeName != 'C-V') return

    const mt_data = lines[index]
    upsert_input = mt_data.substr(+target.dataset.i)

    if (target === focus_word) {
      upsert_activate(upsert_input, 0)
    } else {
      if (focus_word) focus_word.classList.remove('_focus')
      focus_word = target
      focus_word.classList.add('_focus')

      const lower = +focus_word.dataset.p
      const upper = lower + focus_word.dataset.k.length
      lookup_activate(null, mt_data, lower, upper)
    }
  }

  function render_line(idx, hover, focus) {
    const mt_data = lines[idx]
    const use_html = idx == hover || idx == focus
    return use_html ? mt_data.html : mt_data.text
  }
</script>

<div hidden>
  <button data-kbd="r" on:click={() => (_dirty = true)}>R</button>
  <button data-kbd="x" on:click={() => upsert_activate(upsert_input, 0)}
    >X</button>
  <button data-kbd="c" on:click={() => upsert_activate(upsert_input, 1)}
    >C</button>
  <button data-kbd="enter" on:click={() => upsert_activate(upsert_input, 0)}
    >E</button>
</div>

{#each lines as _, index (index)}
  <div
    class="mtl {wtitle && index == 0 ? '_h' : '_p'}"
    on:click={(e) => handle_click(e, index)}
    on:mouseenter={() => (hover_line = index)}>
    {@html render_line(index, hover_line, focus_line)}
  </div>

  {#if $session.privi < 1 && adidx.includes(index)}
    <Aditem type="article" />
  {/if}
{/each}

{#if $lookup_enabled}
  <Lookup {dname} />
{/if}

{#if $upsert_state}
  <Upsert {dname} {label} bind:_dirty />
{/if}
