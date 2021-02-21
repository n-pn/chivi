<script context="module">
  import { onMount } from 'svelte'
  import { u_power } from '$src/stores'

  import Cvline from './Cvdata/Line'
  import AdItem from '$blocks/AdItem'

  import Lookup, {
    input as lookup_input,
    actived as lookup_actived,
    enabled as lookup_enabled,
  } from '$widget/Lookup'

  import Upsert, {
    phrase as upsert_phrase,
    on_tab as upsert_target,
    active as upsert_active,
  } from '$widget/Upsert'

  export function toggle_lookup() {
    lookup_enabled.update((x) => {
      lookup_actived.set(!x)
      return !x
    })
  }

  export function active_upsert(tab) {
    upsert_target.set(tab)
    upsert_active.set(true)
  }

  function gen_context(nodes = [], idx = 0, min = 4, max = 10) {
    let input = ''

    for (let j = idx - 1; j >= 0; j--) {
      const [key] = nodes[j]
      input = key + input
      if (input.length >= min) break
    }

    const lower = input.length
    input += nodes[idx][0]
    const upper = input.length

    let limit = upper + min
    if (limit < max) limit = max

    for (let j = idx + 1; j < nodes.length; j++) {
      const [key] = nodes[j]
      input = input + key
      if (input.length > limit) break
    }

    return [input, lower, upper > lower ? upper : lower + 1]
  }

  function split_input(input) {
    if (!input) return []
    return input.split('\n').map((x) => parse_input(x))
  }

  function parse_input(line) {
    return line.split('\t').map((x) => x.split('ǀ'))
  }

  function random_int(min = 7, max = 15) {
    return Math.floor(Math.random() * (max - min) + min)
  }

  function ads_indexes(max = 100) {
    const res = []
    for (let i = random_int(); i < max; i += random_int()) res.push(i)
    return res
  }
</script>

<script>
  export let cvdata = ''
  export let changed = false

  export let dname = 'various'
  export let bname = 'Tổng hợp'

  $: lines = split_input(cvdata)
  $: adidx = ads_indexes(lines.length)

  let hover_line = 0
  let focus_line = 0
  let focus_word = null

  import read_selection from '$utils/read_selection'

  onMount(() => {
    const action = document.addEventListener('selectionchange', () => {
      const phrase = read_selection()
      if (phrase) $upsert_phrase = phrase
    })

    return () => document.removeEventListener('selectionchange', action)
  })

  function handle_click({ target }, index) {
    if (focus_line != index) focus_line = index
    if (target.nodeName != 'X-V') return

    const idx = +target.dataset.i
    const nodes = lines[index]
    $upsert_phrase = gen_context(nodes, idx)

    if (target === focus_word) {
      $upsert_target = 0
      $upsert_active = true
    } else {
      if (focus_word) focus_word.classList.remove('_focus')
      focus_word = target
      focus_word.classList.add('_focus')

      lookup_input.set(gen_context(nodes, idx, 10, 20))
      lookup_actived.set(true)
    }
  }
</script>

<article class:changed>
  {#each lines as nodes, index (index)}
    <div
      class="chivi"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      <Cvline
        {nodes}
        frags={index == hover_line || index == focus_line}
        title={index == 0} />

      {#if $u_power < 2 && adidx.includes(index)}
        <AdItem type="article" />
      {/if}
    </div>
  {/each}
</article>

{#if $lookup_enabled}
  <Lookup on_top={!$upsert_active} />
{/if}

{#if $upsert_active}
  <Upsert {dname} {bname} bind:changed />
{/if}

<style lang="scss">
  :global(.adsbygoogle) {
    margin-top: 1rem;
  }
</style>
