<script context="module">
  import { page, navigating } from '$app/stores'
  import { config } from '$lib/stores'
  import CvData from '$lib/cv_data'

  import {
    scroll_into_view,
    read_selection,
    next_elem,
    prev_elem,
  } from '$utils/dom_utils.js'

  import Tlspec, { ctrl as tlspec } from '$parts/Tlspec.svelte'
  import Upsert, { ctrl as upsert } from '$parts/Upsert.svelte'
  import Lookup, { ctrl as lookup } from '$parts/Lookup.svelte'

  import Cvline from '$sects/Cvline.svelte'

  import Cvmenu, { ctrl as cvmenu, input } from './CvPage/Cvmenu.svelte'
  import Zhline from './CvPage/Zhline.svelte'

  const hovered = []
  const focused = []

  function remove_classes() {
    focused.forEach((x) => x.classList.remove('focus'))
    hovered.forEach((x) => x.classList.remove('hover'))
    focused.length = 0
    hovered.length = 0
  }
</script>

<script>
  export let cvdata = ''
  export let zhtext = []

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'

  export let on_change = () => {}
  const hide_controls = () => {
    remove_classes()
    cvmenu.deactivate()
  }

  $: cv_lines = CvData.parse_lines(cvdata)
  let article = null

  let l_hover = 0
  let l_focus = 0

  $: if ($navigating) {
    hide_controls()
    l_focus = 0
  }

  function handle_mouse({ target, which }, _index = l_hover) {
    if ($config.render < 0 || which == 3) return // return if in zen mode

    let [nodes, lower, upper] = read_selection()

    switch (target.nodeName) {
      case 'V-N':
      case 'Z-N':
        if (nodes && nodes.length > 1 && nodes.includes(target)) break

        nodes = [target]

        lower = +target.dataset.l
        upper = +target.dataset.u

        if (!target.classList.contains('focus')) break
        return upsert.activate($input, +target.dataset.d % 2 ? 0 : 1)

      case 'CV-DATA':
        l_focus = _index

      case 'ARTICLE':
        hide_controls()

      default:
        return
    }

    change_focus(_index, lower, upper, nodes)
  }

  function change_focus(index, lower, upper, nodes) {
    l_focus = index
    remove_classes()

    const line = article.querySelector(`#L${index}`)
    scroll_into_view(line, article, 'smooth')

    if (!nodes) {
      let child = line.querySelector(`v-n[data-l="${lower}"]`)
      if (!upper && can_skip(child)) child = next_elem(child, true) || child

      if (child) {
        nodes = [child]
        lower = +child.dataset.l
        upper = +child.dataset.u
      } else {
        nodes = []
      }
    }

    input.put([zhtext[index], lower, upper])
    if ($lookup.enabled || $lookup.actived)
      lookup.activate($input, $lookup.enabled)

    for (let node of nodes) {
      node.classList.add('focus')
      focused.push(node)
    }

    const add_hover = (query) => {
      for (let node of line.querySelectorAll(query)) {
        node.classList.add('hover')
        hovered.push(node)
      }
    }

    for (let i = lower; i < upper; i++) {
      add_hover(`[data-l="${i}"]`)
      add_hover(`[data-u="${i + 1}"]`)
    }

    cvmenu.activate(nodes, article)
  }

  function retake_control() {
    if (!article) return
    article.focus()
    change_focus(l_focus, $input.lower, $input.upper)
  }

  function render_html(render, index, hover, focus) {
    if (render != 0) return render > 0
    if (index == hover) return true

    if (index > focus - 2 && focus < focus + 2) return true
    if (focus == 0) return index == zhtext.length - 1
    return index == 0 && focus == zhtext.length - 1
  }

  function move_left(shift = false) {
    let node = prev_elem(focused[0], true)

    let max_scan = 4
    let focus = l_focus

    while (!node && max_scan-- > 0) {
      focus = (focus - 1 + zhtext.length) % zhtext.length
      node = article.querySelector(`#L${focus} cv-line`).lastChild

      while (node && node.nodeName != 'V-N') {
        node = node.nodeType == 1 ? node.lastChild : node.previousSibling
      }

      while (can_skip(node)) node = prev_elem(node, true)
    }

    if (!node) return
    const nodes = shift ? [node].concat(focused) : [node]

    while (node && +node.dataset.d < 1) {
      nodes.unshift(node)
      node = prev_elem(node)
    }

    const lower = +nodes[0].dataset.l
    const upper = shift ? $input.upper : +nodes[0].dataset.u

    return change_focus(focus, lower, upper, nodes)
  }

  function can_skip(node) {
    return node ? +node.dataset.d < 1 : false
  }

  function move_right(shift = false) {
    let node = next_elem(focused[focused.length - 1], true)

    let max_scan = 4
    let focus = l_focus

    while (!node && max_scan > 0) {
      max_scan -= 1

      focus = (focus + 1) % zhtext.length
      node = article.querySelector(`#L${focus} cv-line`).firstChild

      while (node && node.nodeName != 'V-N') {
        node = node.nodeType == 1 ? node.firstChild : node.nextSibling
      }

      while (can_skip(node)) node = next_elem(node, true)
    }

    if (!node) return

    const nodes = shift ? focused.concat([node]) : [node]

    while (can_skip(node)) {
      nodes.push(node)
      node = next_elem(node)
    }

    const lower = shift ? $input.lower : +nodes[nodes.length - 1].dataset.l
    const upper = +nodes[nodes.length - 1].dataset.u

    return change_focus(focus, lower, upper, nodes)
  }

  // $: console.log($input)

  function handle_keydown(event) {
    if (article != document.activeElement || $config.render < 0) return

    let focus = l_focus

    switch (event.key) {
      case 'Enter':
        event.preventDefault()
        let dic = 1
        if (focused.length == 1 && +focused[0].dataset.d % 2) dic = 0
        return setTimeout(() => upsert.activate($input, dic), 10)

      case 'ArrowUp':
        event.preventDefault()
        focus = (focus - 1 + zhtext.length) % zhtext.length
        return change_focus(focus, 0, 0)

      case 'ArrowDown':
        event.preventDefault()
        focus = (focus + 1) % zhtext.length
        return change_focus(focus, 0, 0)

      case 'ArrowLeft':
        event.preventDefault()
        return move_left(event.shiftKey)

      case 'ArrowRight':
        event.preventDefault()
        return move_right(event.shiftKey)
    }
  }
</script>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_render(-1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_render(1)}>G</button>
  <button data-kbd="c" on:click={() => upsert.activate($input, 1)}>C</button>
</div>

<svelte:window on:keydown={handle_keydown} />

<article
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  bind:this={article}
  on:blur={hide_controls}
  on:mouseup={handle_mouse}>
  <header>
    <slot name="header">Dịch nhanh</slot>
  </header>

  {#key zhtext}
    {#each cv_lines as input, index (index)}
      <cv-data
        id="L{index}"
        class:debug={$config.render == 1}
        class:focus={index == l_focus}
        on:mouseenter={() => (l_hover = index)}>
        {#if $config.showzh}
          <Zhline ztext={zhtext[index]} plain={$config.render < 0} />
        {/if}
        <Cvline
          {input}
          focus={render_html($config.render, index, l_hover, l_focus)} />
      </cv-data>
    {/each}
  {/key}

  <Cvmenu />
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
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  // prettier-ignore
  cv-data {
    display: block;
    margin-top: 1em;
    color: var(--fgcolor, var(--fg-main));

    :global(.app-ff-1) & { font-family: var(--font-sans); }
    :global(.app-ff-2) & { font-family: var(--font-serif); }
    :global(.app-ff-3) & { font-family: Nunito Sans, var(--font-sans); }
    :global(.app-ff-4) & { font-family: Lora, var(--font-serif); }

    // &.focus {
    //   :global(.tm-light) & { @include bgcolor(warning, 2, 1); }
    //   :global(.tm-warm) & { @include bgcolor(warning, 0, 4); }
    //   :global(.tm-dark) & { @include bgcolor(neutral, 8, 9); }
    //   :global(.tm-oled) & { @include bgcolor(neutral, 9, 8); }
    // }
  }

  cv-data:first-of-type {
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
