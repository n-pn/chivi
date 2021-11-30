<script context="module">
  import { page, navigating } from '$app/stores'
  import { config } from '$lib/stores'

  import { scroll_into_view, read_selection } from '$utils/dom_utils.js'

  import Tlspec, { ctrl as tlspec } from '$parts/Tlspec.svelte'
  import Upsert, { ctrl as upsert } from '$parts/Upsert.svelte'
  import Lookup, { ctrl as lookup } from '$parts/Lookup.svelte'
  import Cvline, { Mtline } from '$sects/Cvline.svelte'

  import Cvmenu, { ctrl as cvmenu, input } from './Cvdata/Cvmenu.svelte'
  import Zhline from './Cvdata/Zhline.svelte'
</script>

<script>
  export let cvdata = ''
  export let zhtext = []

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'

  export let on_change = () => {}
  const hide_cvmenu = () => setTimeout(cvmenu.deactivate, 50)

  $: cv_lines = Mtline.parse_lines(cvdata)
  let article = null

  let l_hover = 0
  let l_focus = 0
  let hovered = []
  let focused = []

  $: if ($navigating && article) {
    cvmenu.deactivate()
    change_focus(0, 0, 1)
  }

  function handle_mouse({ target }, _index = l_hover) {
    if ($config.reader == 1) return // return if in zen mode

    const { nodeName } = target
    if (nodeName == 'CV-ITEM') return

    let [nodes, lower, upper] = read_selection()
    if (!nodes) {
      if (nodeName != 'V-N' && nodeName != 'Z-N') return // hide_cvmenu()
      nodes = [target]

      lower = +target.dataset.l
      upper = +target.dataset.u
    }

    change_focus(_index, lower, upper, nodes)

    // if (selected.includes(target)) {
    //   upsert.activate($input, 0)
    // } else {
    //   selected.forEach((x) => x.classList.remove('focus'))
    //   selected = [target]
    //   target.classList.add('focus')

    //   if ($lookup.enabled || $lookup.actived) {
    //     lookup.activate($input, $lookup.enabled)
    //   }
    // }
  }

  function change_focus(index, lower, upper, nodes) {
    l_focus = index

    focused.forEach((x) => x.classList.remove('focus'))
    hovered.forEach((x) => x.classList.remove('hover'))

    const line = article.querySelector(`#L${index}`)
    scroll_into_view(line, article, 'smooth')

    if (!nodes) {
      const child = line.querySelector('v-n:not([data-d="1"])')
      if (child) {
        nodes = [child]
        lower = +child.dataset.l
        upper = +child.dataset.u
      } else {
        nodes = []
      }
    }

    focused = nodes
    $input = [zhtext[index], lower, upper]

    if (nodes.length > 0) {
      focused.forEach((x) => x.classList.add('focus'))
      cvmenu.activate(nodes[nodes.length - 1], article)
    }

    hovered = []

    for (let i = lower; i < upper; i++) {
      hovered.concat(line.querySelectorAll(`[data-l="${i}"]`))
      hovered.concat(line.querySelectorAll(`[data-u="${i + 1}"]`))
    }

    hovered.forEach((x) => x.addClass('hover'))
  }

  function retake_control() {
    if (!article) return
    article.focus()
    scroll_into_view('#L' + l_focus, article)
  }

  function render_html(reader, index, hover, focus) {
    if (reader > 0) return reader == 2
    if (index == hover) return true

    if (index > focus - 2 && focus < focus + 2) return true
    if (focus == 0) return index == zhtext.length - 1
    return index == 0 && focus == zhtext.length - 1
  }

  function handle_keydown(event) {
    if (article != document.activeElement || $config.reader == '1') return

    let focus = l_focus

    switch (event.key) {
      case 'ArrowUp':
        event.preventDefault()

        focus = focus == 0 ? zhtext.length - 1 : focus - 1
        change_focus(focus, 0, 1)

        break

      case 'ArrowDown':
        event.preventDefault()
        focus = focus >= zhtext.length - 1 ? 0 : focus + 1

        change_focus(focus, 0, 1)
        break
    }
  }
</script>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_reader(1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_reader(2)}>G</button>
  <button data-kbd="x" on:click={() => upsert.activate($input, 0)}>X</button>
  <button data-kbd="c" on:click={() => upsert.activate($input, 1)}>C</button>
</div>

<svelte:window on:keydown={handle_keydown} />

<article
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  bind:this={article}
  on:blur={hide_cvmenu}
  on:mouseup={handle_mouse}>
  <header>
    <slot name="header">Dịch nhanh</slot>
  </header>

  {#key zhtext}
    {#each cv_lines as input, index (index)}
      <cv-data
        id="L{index}"
        class:debug={$config.reader == 2}
        class:focus={index == l_focus}
        on:mouseenter={() => (l_hover = index)}>
        {#if $config.showzh}
          <Zhline ztext={zhtext[index]} plain={$config.reader == 1} />
        {/if}
        <Cvline
          {input}
          focus={render_html($config.reader, index, l_hover, l_focus)} />
      </cv-data>
    {/each}
  {/key}

  {#if $cvmenu.actived}<Cvmenu />{/if}
</article>

{#if $lookup.enabled || $lookup.actived}
  <Lookup {dname} on_destroy={retake_control} />
{/if}

{#if $upsert.state > 0}
  <Upsert {dname} {d_dub} {on_change} on_destroy={retake_control} />
{/if}

{#if $tlspec.actived}
  <Tlspec
    {dname}
    {d_dub}
    slink="{$page.path}#L{l_hover}"
    on_destroy={retake_control} />
{/if}

<style lang="scss">
  article {
    --pad: calc(var(--gutter) * 0.5);

    position: relative;
    min-height: 50vh;
    padding: 0 var(--pad) var(--verpad);

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
    margin: 0 var(--pad) var(--verpad);
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  // prettier-ignore
  cv-data {
    display: block;
    position: relative;
    padding: 0 var(--pad);
    color: var(--fgcolor, #{color(gray, 8)});
    @include tm-dark { --fgcolor: #{color(gray, 3)}; }

    :global(.app-ff-1) & { font-family: var(--font-sans); }
    :global(.app-ff-2) & { font-family: var(--font-serif); }
    :global(.app-ff-3) & { font-family: Nunito Sans, var(--font-sans); }
    :global(.app-ff-4) & { font-family: Lora, var(--font-serif); }

    &.focus {
      @include bgcolor(main);

      @include tm-oled {
        @include bgcolor(neutral, 9);
      }

      &:before {
        --width: 3px;

        position: absolute;
        display: inline-block;
        content: '';
        width: var(--width);
        left: calc(var(--width) * -0.5);
        height: 100%;
        @include bgcolor(primary, 5);
      }
    }
  }

  cv-data:first-of-type {
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

  cv-data:not(:first-of-type) {
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
