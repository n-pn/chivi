<script context="module">
  import Lookup, {
    input as lookup_input,
    actived as lookup_actived,
    enabled as lookup_enabled,
  } from '$lib/widgets/Lookup.svelte'

  import Upsert, {
    phrase as upsert_phrase,
    on_tab as upsert_target,
    active as upsert_active,
  } from '$lib/widgets/Upsert.svelte'

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
</script>

<script>
  import { onMount } from 'svelte'

  import { split_cvdata, render_text, render_html } from '$lib/cvdata'

  export let cvdata = ''
  export let changed = false

  export let dname = 'various'
  export let bname = 'Tổng hợp'

  $: lines = split_cvdata(cvdata)

  let hover_line = -1
  let focus_line = -1
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

  let texts = []
  let htmls = []

  // reset cached content if changed
  $: if (cvdata) {
    texts = []
    htmls = []
  }

  function render_line(idx, hover, focus) {
    const use_html = idx == hover || idx == focus

    const nodes = lines[idx]
    if (use_html) return (htmls[idx] ||= render_html(nodes))
    return (texts[idx] ||= render_text(nodes))
  }
</script>

<article class:changed>
  {#each lines as _, index (index)}
    <div
      class="mtl {index > 0 ? '_p' : '_h'}"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      {@html render_line(index, hover_line, focus_line)}
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

  .mtl {
    --fgcolor: #{color(neutral, 8)};
    color: var(--fgcolor);

    @include tm-dark {
      --fgcolor: #{color(neutral, 3)};
    }

    &._h {
      font-weight: 400;
      // @include fgcolor(neutral, 8);

      @include props(
        font-size,
        rem(22px),
        rem(23px),
        rem(24px),
        rem(26px),
        rem(28px)
      );
      @include props(line-height, 1.75rem, 1.875rem, 2rem, 2.25rem, 2.5rem);
    }

    &._p {
      @include props(margin-top, 1rem, 1.125rem, 1.25rem, 1.375rem, 1.5rem);
      margin-bottom: 0;
      text-align: justify;
      text-justify: auto;

      @include props(
        font-size,
        rem(18px),
        rem(19px),
        rem(20px),
        rem(21px),
        rem(22px)
      );
    }
  }

  @mixin change-color($color: blue) {
    cursor: pointer;
    --border: #{color($color, 4)};
    --active: #{color($color, 6)};

    :global(.tm-dark) & {
      --border: #{color($color, 6)};
      --active: #{color($color, 4)};
    }
  }

  :global(x-v) {
    --border: transparent;
    --active: #{color(primary, 9)};

    color: var(--fgcolor);
    border-bottom: 1px solid transparent;

    .mtl:hover & {
      border-color: var(--border);
    }
  }

  :global(x-v:hover),
  :global(x-v._focus) {
    color: var(--active);
  }

  :global(x-v[data-d='1']) {
    @include change-color(teal);
  }

  :global(x-v[data-d='2']) {
    @include change-color(blue);
  }

  :global(x-v[data-d='3']) {
    @include change-color(green);
  }

  :global(x-v[data-d='9']) {
    @include change-color(gray);
  }
</style>
