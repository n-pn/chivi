<script context="module">
  import { onMount } from 'svelte'

  import LookupPanel from '$melds/LookupPanel'
  import UpsertModal from '$melds/UpsertModal'
  import ConvertLine from './Convert/Line'

  import {
    lookup_input,
    upsert_input,
    upsert_ontab,
    lookup_actived,
    lookup_enabled,
    upsert_actived,
  } from '$src/stores'

  export function toggle_lookup() {
    lookup_enabled.update((x) => {
      lookup_actived.set(!x)
      return !x
    })
  }

  export function active_upsert(focus) {
    upsert_ontab.update((x) => focus || x)
    upsert_actived.set(true)
  }

  function gen_context(nodes = [], idx = 0, min = 4, max = 10) {
    let output = ''

    for (let j = idx - 1; j >= 0; j--) {
      const [key] = nodes[j]
      output = key + output
      if (output.length >= min) break
    }

    const lower = output.length
    output += nodes[idx][0]
    const upper = output.length

    let limit = upper + min
    if (limit < max) limit = max

    for (let j = idx + 1; j < nodes.length; j++) {
      const [key] = nodes[j]
      output = output + key
      if (output.length > limit) break
    }

    return [output, lower, upper]
  }

  function parse_chivi(line) {
    return line.split('\t').map((x) => x.split('¦'))
  }
</script>

<script>
  export let input = ''
  $: lines = input.split('\n').map((x) => parse_chivi(x))

  export let dirty = false

  let hover_line = 0
  let focus_line = 0
  let focus_word = null

  import read_selection from '$utils/read_selection'

  onMount(() => {
    const event = document.addEventListener('selectionchange', () => {
      const input = read_selection()

      if (input) {
        $upsert_input = input
        $upsert_ontab = 0
      }
    })

    return () => document.removeEventListener('selectionchange', event)
  })

  function handle_click({ target }, index) {
    if (focus_line != index) focus_line = index
    if (target.nodeName != 'X-V') return

    const idx = +target.dataset.i
    const nodes = lines[index]
    upsert_input.set(gen_context(nodes, idx))

    if (target === focus_word) {
      upsert_ontab.set(0)
      upsert_actived.set(true)
    } else {
      if (focus_word) focus_word.classList.remove('_focus')
      focus_word = target
      focus_word.classList.add('_focus')

      lookup_input.set(gen_context(nodes, idx, 10, 20))
      lookup_actived.set(true)
    }
  }
</script>

<article class:dirty>
  {#each lines as nodes, index (index)}
    <div
      class="chivi"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      <ConvertLine
        {nodes}
        frags={index == hover_line || index == focus_line}
        title={index == 0} />
    </div>
  {/each}
</article>

{#if $lookup_enabled}
  <LookupPanel on_top={!$upsert_actived} />
{/if}

{#if $upsert_actived}
  <UpsertModal bind:dirty />
{/if}
