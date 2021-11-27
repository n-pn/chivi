<script context="module">
  import Tlspec, { ctrl as tlspec } from '$parts/Tlspec.svelte'
  import Upsert, { ctrl as upsert } from '$parts/Upsert.svelte'
  import Lookup, { ctrl as lookup } from '$parts/Lookup.svelte'

  import Cvmenu, { ctrl as cvmenu, input } from '$parts/Cvmenu.svelte'
</script>

<script>
  import { onMount } from 'svelte'
  import { page, navigating } from '$app/stores'

  import Cvline, { Mtline } from '$sects/Cvline.svelte'

  import read_selection from '$utils/read_selection'
  import { config } from '$lib/stores'

  export let cvdata = ''
  export let zhtext = []

  export let wtitle = true

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'

  export let on_change = () => {}

  $: cv_lines = Mtline.parse_lines(cvdata)
  let article = null

  let state = { hover: 0, focus: 0 }
  let cvterm = null

  const hide_cvmenu = () => setTimeout(cvmenu.deactivate, 50)

  $: if ($navigating) {
    state = { hover: 0, focus: 0 }
    cvterm = null

    cvmenu.deactivate()
    upsert.deactivate()
  }
  $: ztext = zhtext[state.hover] || ''

  onMount(() => {
    let timeout = null

    function on_selection() {
      if ($config.reader == 1) return

      const [lower, upper] = read_selection()
      if (upper > 0) $input = [ztext, lower, upper]

      const selection = document.getSelection()
      if (selection.isCollapsed) return

      const range = selection.getRangeAt(0)
      cvmenu.activate(range, article)
    }

    const action = document.addEventListener('selectionchange', () => {
      if (timeout) clearTimeout(timeout)
      timeout = setTimeout(on_selection, 250)
    })

    return () => document.removeEventListener('selectionchange', action)
  })

  function handle_click({ target }) {
    if (state.focus != state.hover) state.focus = state.hover

    if ($config.reader == 1) return // return if in zen mode
    if (target.nodeName != 'V-N') {
      if (target.nodeName != 'CV-ITEM') hide_cvmenu()
      return
    }

    cvmenu.activate(target, article)

    const lower = +target.dataset.i
    const upper = lower + +target.dataset.l
    $input = [ztext, lower, upper]

    if (target == cvterm) {
      upsert.activate($input, 0)
    } else {
      cvterm?.classList.remove('focus')
      target.classList.add('focus')
      cvterm = target

      if ($lookup.enabled || $lookup.actived) {
        lookup.activate($input, $lookup.enabled)
      }
    }
  }

  function regain_focus() {
    if (!article) return
    article.focus()

    const elem = article.querySelector('#L' + state.focus)
    if (scroll_uneeded(elem)) return

    elem?.scrollIntoView({ behavior: 'auto', block: 'nearest' })
  }

  function scroll_uneeded(elem) {
    if (!elem) return true
    const rect = elem.getBoundingClientRect()
    return rect.top > 0 && rect.bottom <= window.innerHeight
  }

  function show_html(reader, index, state) {
    if (reader > 0) return reader == 2
    if (index == state.hover) return true
    return index > state.focus - 2 && index < state.focus + 2
  }

  function switch_reader(reader_mode = 0) {
    if ($config.reader == reader_mode) $config.reader = 0
    else $config.reader = reader_mode
  }
</script>

<div hidden>
  <button data-kbd="a" on:click={() => ($config.showzh = !$config.showzh)}
    >A</button>
  <button data-kbd="z" on:click={() => switch_reader(1)}>Z</button>
  <button data-kbd="z" on:click={() => switch_reader(1)}>Z</button>
  <button data-kbd="g" on:click={() => switch_reader(2)}>G</button>
  <button data-kbd="x" on:click={() => upsert.activate($input, 0)}>X</button>
  <button data-kbd="c" on:click={() => upsert.activate($input, 1)}>C</button>
</div>

<article
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  bind:this={article}
  on:blur={hide_cvmenu}
  on:click={handle_click}>
  <header>
    <slot name="header">Dịch nhanh</slot>
  </header>

  {#key zhtext}
    {#each cv_lines as input, index (index)}
      <cv-data
        id="L{index}"
        class={wtitle && index == 0 ? 'h' : 'p'}
        class:debug={$config.reader == 2}
        class:focus={index == state.focus}
        on:mouseenter={() => (state.hover = index)}>
        {#if $config.showzh}<zh-line>{zhtext[index]}</zh-line>{/if}
        <Cvline {input} focus={show_html($config.reader, index, state)} />
      </cv-data>
    {/each}
  {/key}

  {#if $cvmenu.actived}<Cvmenu />{/if}
</article>

{#if $lookup.enabled || $lookup.actived}
  <Lookup {dname} on_destroy={regain_focus} />
{/if}

{#if $upsert.state > 0}
  <Upsert {dname} {d_dub} {on_change} on_destroy={regain_focus} />
{/if}

{#if $tlspec.actived}
  <Tlspec
    {dname}
    {d_dub}
    slink="{$page.path}#L{state.hover}"
    on_destroy={regain_focus} />
{/if}

<style lang="scss">
  article {
    position: relative;
    min-height: 50vh;
    padding: 0 var(--gutter) var(--verpad);

    margin-left: calc(-1 * var(--gutter));
    margin-right: calc(-1 * var(--gutter));

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

    :global(.tm-warm) & {
      background: #fffbeb;
    }

    :global(.adsbygoogle) {
      margin-top: 1rem;
    }

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
    }
  }

  header {
    @include border(--bd-main, $loc: bottom);
    margin-bottom: var(--verpad);
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  cv-data {
    display: block;
    color: var(--fgcolor, #{color(gray, 8)});
    // prettier-ignore
    @include tm-dark { --fgcolor: #{color(gray, 3)}; }

    :global(.app-ff-1) & {
      font-family: var(--font-sans);
    }

    :global(.app-ff-2) & {
      font-family: var(--font-serif);
    }

    :global(.app-ff-3) & {
      font-family: Nunito Sans, var(--font-sans);
    }

    :global(.app-ff-4) & {
      font-family: Lora, var(--font-serif);
    }
  }

  zh-line {
    display: block;
    font-family: san-serif;
    // font-size: 0.95em;
    line-height: 1.4em;
    letter-spacing: 0.04em;
    margin-bottom: 0.1em;
    @include tm-light {
      color: color(neutral, 6);
    }

    @include tm-dark {
      color: color(neutral, 4);
    }
  }

  cv-data.h {
    font-weight: 400;
    line-height: 1.4em;

    @include bps(font-size, rem(23px), rem(24px), rem(26px), rem(28px));

    :global(.app-fs-1) & {
      @include bps(font-size, rem(22px), rem(23px), rem(25px), rem(27px));
    }

    :global(.app-fs-5) & {
      @include bps(font-size, rem(24px), rem(25px), rem(26px), rem(29px));
    }
  }

  cv-data.p {
    text-align: justify;
    text-justify: auto;
    line-height: var(--textlh, 160%);

    // @include bps(margin-top, 1.125em, 1.25em, 1.375em, 1.5em);
    margin-top: 1em;

    :global(.app-fs-1) & {
      @include bps(font-size, rem(16px), rem(17px), rem(18px), rem(19px));
    }

    :global(.app-fs-2) & {
      @include bps(font-size, rem(18px), rem(19px), rem(20px), rem(21px));
    }

    :global(.app-fs-3) & {
      @include bps(font-size, rem(19px), rem(20px), rem(21px), rem(22px));
    }

    :global(.app-fs-4) & {
      @include bps(font-size, rem(20px), rem(21px), rem(22px), rem(23px));
    }
  }

  :global {
    .crumb {
      // float: left;

      &._link {
        color: inherit;
        &:hover {
          @include fgcolor(primary, 5);
        }
      }
    }
  }
</style>
