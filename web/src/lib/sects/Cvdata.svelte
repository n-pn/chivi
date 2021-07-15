<script context="module">
  import Lookup, {
    input as lookup_input,
    actived as lookup_actived,
    enabled as lookup_enabled,
  } from '$parts/Lookup.svelte'

  import Upsert, {
    state as upsert_state,
    activate as upsert_activate,
  } from '$parts/Upsert.svelte'

  export function toggle_lookup() {
    lookup_enabled.update((x) => {
      lookup_actived.set(!x)
      return !x
    })
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
  import { session } from '$app/stores'

  import * as cvlib from '$lib/cvdata'
  import Aditem, { ad_indexes } from '$molds/Aditem.svelte'

  export let cvdata = ''
  export let _dirty = false

  export let dname = 'various'
  export let label = 'Tổng hợp'

  $: lines = cvlib.split_input(cvdata)
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
    if (target.nodeName != 'X-V') return

    const idx = +target.dataset.i
    const nodes = lines[index]
    upsert_input = gen_context(nodes, idx)

    if (target === focus_word) {
      upsert_activate(upsert_input, 0)
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
    if (use_html) return (htmls[idx] ||= cvlib.render(nodes, 'html'))
    return (texts[idx] ||= cvlib.render(nodes, 'text'))
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

<article class="article" class:_dirty>
  {#each lines as _, index (index)}
    <div
      class="mtl {index > 0 ? '_p' : '_h'}"
      on:click={(e) => handle_click(e, index)}
      on:mouseenter={() => (hover_line = index)}>
      {@html render_line(index, hover_line, focus_line)}
    </div>

    {#if $session.privi < 1 && adidx.includes(index)}
      <Aditem type="article" />
    {/if}
  {/each}
</article>

{#if $lookup_enabled}
  <Lookup {dname} />
{/if}

{#if $upsert_state > 0}
  <Upsert {dname} {label} bind:_dirty />
{/if}

<style lang="scss">
  :global(.adsbygoogle) {
    margin-top: 1rem;
  }

  .article {
    padding: var(--verpad) var(--gutter);

    @include fluid(margin-left, calc(-1 * var(--gutter)), $lg: 0);
    @include fluid(margin-right, calc(-1 * var(--gutter)), $lg: 0);

    @include bdradi();
    @include fgcolor(secd);
    @include bgcolor(tert);
    @include shadow(1);
  }

  .mtl {
    --fgcolor: #{color(gray, 8)};
    color: var(--fgcolor);

    @include tm-dark {
      --fgcolor: #{color(gray, 3)};
    }

    &._h {
      font-weight: 400;
      // @include fgcolor(neutral, 8);

      @include fluid(
        font-size,
        rem(22px),
        rem(23px),
        rem(24px),
        rem(26px),
        rem(28px)
      );
      @include fluid(line-height, 1.75rem, 1.875rem, 2rem, 2.25rem, 2.5rem);
    }

    &._p {
      @include fluid(margin-top, 1rem, 1.125rem, 1.25rem, 1.375rem, 1.5rem);
      margin-bottom: 0;
      text-align: justify;
      text-justify: auto;

      @include fluid(
        font-size,
        rem(18px),
        rem(19px),
        rem(20px),
        rem(21px),
        rem(22px)
      );

      @include fluid(line-height, 1.75rem, 1.875rem, 2rem, 2.25rem);
    }
  }

  @mixin cv-token($color: blue) {
    cursor: pointer;
    position: relative;
    --border: #{color($color, 4)};
    --active: #{color($color, 6)};

    :global(.tm-dark) & {
      --border: #{color($color, 6)};
      --active: #{color($color, 4)};
    }
  }

  :global(x-v) {
    --border: transparent;
    --active: var(--fgcolor);

    color: var(--fgcolor);

    .mtl:hover & {
      border-bottom: 1px solid var(--border);
    }
  }

  :global(x-v:hover),
  :global(x-v._focus) {
    color: var(--active);
  }

  // :global(x-v[data-d='1']) {
  //   @include cv-token(gray);
  // }

  :global(x-v[data-d='2']) {
    @include cv-token(blue);
  }

  :global(x-v[data-d='3']) {
    @include cv-token(green);
  }

  :global(x-v[data-d='4']) {
    @include cv-token(teal);
  }

  :global(x-v[data-d='9']) {
    @include cv-token(gray);
  }
</style>
