<script context="module">
  import { onMount } from 'svelte'

  import AdBanner from '$atoms/AdBanner'

  import LookupPanel from '$melds/LookupPanel'
  import UpsertModal, { dict_upsert } from '$melds/UpsertModal'

  import ConvertLine from './Convert/Line'

  import {
    // self_uname,
    self_power,
    upsert_input,
    lookup_input,
    upsert_ontab,
    upsert_actived,
    lookup_actived,
    lookup_enabled,
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

  function make_ads_array(limit = 1, max = 30, min = 20) {
    const res = []
    let idx = random_int(15, 5)

    while (idx < limit) {
      res.push(idx)
      idx += random_int(max, min)
    }

    return res
  }

  function random_int(max = 30, min = 20) {
    return Math.floor(Math.random() * (max - min)) + min
  }

  function make_bounds(nodes = [], idx = 0, min = 4, max = 10) {
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
  export let dname = 'dich-nhanh'

  $: place_ads_here = make_ads_array(input.length)

  let holder = null

  let hover_line = 0
  let focus_line = 0
  let focus_word = null

  import read_selection from '$utils/read_selection'

  onMount(() => {
    if (holder) holder.focus()

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
    upsert_input.set(make_bounds(nodes, idx))

    if (target === focus_word) {
      upsert_ontab.set(0)
      upsert_actived.set(true)
    } else {
      if (focus_word) focus_word.classList.remove('_focus')
      focus_word = target
      focus_word.classList.add('_focus')

      lookup_input.set(make_bounds(nodes, idx, 8, 20))
      lookup_actived.set(true)
    }
  }

  function handle_keypress(evt) {
    if ($upsert_actived) return
    if (evt.ctrlKey) return

    switch (evt.key) {
      case '\\':
        trigger_lookup()
        break

      case 'r':
        evt.stopPropagation()
        if ($self_power > 0) dirty = true
        break

      case 'x':
        evt.stopPropagation()
        active_upsert(0)
        break

      case 'c':
        evt.stopPropagation()
        active_upsert(1)
        break

      default:
        if (evt.keycode == 46 && evt.shiftKey) delete_focus_word()
        else if (evt.keyCode == 13) active_upsert()
    }
  }

  async function delete_focus_word() {
    if (!focus_word || $self_power < 1) return

    const key = focus_word.dataset.k
    const dic = +focus_word.dataset.d == 2 ? 'generic' : dname

    const res = await dict_upsert(fetch, dic, key, '')
    return res.ok
  }
</script>

<article
  class:dirty
  tabindex="-1"
  bind:this={holder}
  on:keydown={handle_keypress}>
  {#each lines as nodes, index (index)}
    <div
      class="chivi"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      <ConvertLine
        {nodes}
        {index}
        frags={index == hover_line || index == focus_line}
        title={index == 0} />
    </div>

    {#if place_ads_here.includes(index)}
      <AdBanner type="in-article" />
    {/if}
  {/each}
</article>

{#if $lookup_enabled}
  <LookupPanel on_top={!$upsert_actived} />
{/if}

{#if $upsert_actived}
  <UpsertModal bind:dirty />
{/if}

<style lang="scss">
  article {
    padding: 0.75rem 0;
    word-wrap: break-word;

    &.dirty {
      @include fgcolor(neutral, 6);
    }

    :global(h1) {
      font-weight: 300;
      @include fgcolor(neutral, 9);

      $font-sizes: screen-vals(
        rem(24px),
        rem(25px),
        rem(26px),
        rem(28px),
        rem(30px)
      );
      $line-heights: screen-vals(1.75rem, 1.875rem, 2rem, 2.25rem, 2.5rem);

      @include apply(font-size, $font-sizes);
      @include apply(line-height, $line-heights);
    }

    :global(p) {
      text-align: justify;
      text-justify: auto;

      $font-sizes: screen-vals(
        rem(18px),
        rem(19px),
        rem(20px),
        rem(21px),
        rem(22px)
      );
      @include apply(font-size, $font-sizes);
    }

    :global(p),
    > :global(section) {
      $margin-tops: screen-vals(1rem, 1.125rem, 1.25rem, 1.375rem, 1.5rem);
      @include apply(margin-top, $margin-tops);
    }

    :global(cite) {
      text-transform: capitalize;
      font-style: normal;
      // font-variant: small-caps;
    }
  }
</style>
