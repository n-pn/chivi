<script context="module">
  import Tlspec, { state as tlspec_state } from '$parts/Tlspec.svelte'
  import Upsert, {
    state as upsert_state,
    activate as upsert_activate,
  } from '$parts/Upsert.svelte'
  import Lookup, {
    enabled as lookup_enabled,
    activate as lookup_activate,
  } from '$parts/Lookup.svelte'

  import Cvmenu, {
    state as cvmenu_state,
    activate as cvmenu_activate,
    input,
  } from '$parts/Cvmenu.svelte'

  import Cvline, { parse_lines } from '$sects/Cvline.svelte'
</script>

<script>
  import { onMount } from 'svelte'
  import { browser } from '$app/env'
  import { page } from '$app/stores'

  import read_selection from '$utils/read_selection'
  import { config, zh_text } from '$lib/stores'

  export let cvdata = ''
  export let zhtext = []

  export let wtitle = true

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'
  export let debug = false

  export let on_change = () => {}

  $: cv_lines = parse_lines(cvdata)

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

    if (target.nodeName == 'V-N') cvmenu_activate(target, article)
    else return cvmenu_state.set(0)

    const lower = +target.dataset.i
    const upper = lower + +target.dataset.l
    $input = [zhtext[index], lower, upper]

    if (target == focus_word) {
      upsert_activate($input, 0)
    } else {
      if (focus_word) focus_word.classList.remove('focus')
      target.classList.add('focus')
      focus_word = target
      if ($lookup_enabled) lookup_activate($input)
    }
  }
</script>

<div hidden>
  <button data-kbd="r" on:click={on_change}>R</button>
  <button data-kbd="g" on:click={() => (debug = !debug)}>G</button>
  <button data-kbd="x" on:click={() => upsert_activate($input, 0)}>X</button>
  <button data-kbd="c" on:click={() => upsert_activate($input, 1)}>C</button>
</div>

<cvdata-wrap bind:this={article}>
  <article class="cvdata" class:debug>
    <slot name="header">Dịch nhanh</slot>

    {#each cv_lines as cv_line, index (index)}
      <cv-data
        id="L{index}"
        class={wtitle && index == 0 ? 'h' : 'p'}
        class:debug
        class:focus={index == focus_line}
        on:click={(e) => handle_click(e, index)}
        on:mouseenter={() => (hover_line = index)}>
        {#if $config.showzh}
          <zh-line>{zhtext[index]}</zh-line>
        {/if}
        <Cvline
          input={cv_line}
          focus={debug ||
            index == hover_line ||
            (index > focus_line - 2 && index < focus_line + 2)} />
      </cv-data>
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

  .cvdata {
    min-height: 50vh;
    padding: 0 var(--gutter) var(--verpad);

    margin-left: calc(-1 * var(--gutter));
    margin-right: calc(-1 * var(--gutter));

    font-family: var(--font-serif, serif);

    @include fgcolor(secd);
    @include bgcolor(tert);
    @include shadow(1);

    @include bp-min(tl) {
      margin-left: 0;
      margin-right: 0;

      @include bdradi();
      @include tm-dark {
        @include linesd(--bd-soft, $ndef: false, $inset: false);
      }
    }

    .tm-warm & {
      background: #fffbeb;
    }

    .adsbygoogle {
      margin-top: 1rem;
    }

    cite {
      font-style: normal;
      font-variant: small-caps;
    }
  }

  cv-data {
    display: block;
    color: var(--fgcolor, #{color(gray, 8)});
    // prettier-ignore
    @include tm-dark() { --fgcolor: #{color(gray, 3)}; }
  }

  zh-line {
    font-family: san-serif;
    // font-size: 0.95em;
  }

  cv-data.h {
    font-weight: 400;
    line-height: 1.4em;

    @include bps(font-size, rem(23px), rem(24px), rem(26px), rem(28px));

    :global(.app-fs-xs) & {
      @include bps(font-size, rem(22px), rem(23px), rem(25px), rem(27px));
    }

    :global(.app-fs-xl) & {
      @include bps(font-size, rem(24px), rem(25px), rem(26px), rem(29px));
    }
  }

  cv-data.p {
    text-align: justify;
    text-justify: auto;
    line-height: 1.7em;

    // @include bps(margin-top, 1.125em, 1.25em, 1.375em, 1.5em);
    margin-top: 1em;

    :global(.app-fs-xs) & {
      @include bps(font-size, rem(16px), rem(17px), rem(18px), rem(19px));
    }

    :global(.app-fs-sm) & {
      @include bps(font-size, rem(18px), rem(19px), rem(20px), rem(21px));
    }

    :global(.app-fs-md) & {
      @include bps(font-size, rem(19px), rem(20px), rem(21px), rem(22px));
    }

    :global(.app-fs-lg) & {
      @include bps(font-size, rem(20px), rem(21px), rem(22px), rem(23px));
    }

    :global(.app-fs-xl) & {
      @include bps(font-size, rem(22px), rem(23px), rem(24px), rem(25px));
    }
  }
</style>
