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
</script>

<script>
  export let cvdata = ''
  export let zhtext = []

  export let dname = 'various'
  export let d_dub = 'Tổng hợp'

  export let on_change = () => {}
  const hide_cvmenu = () => setTimeout(cvmenu.deactivate, 10)

  $: cv_lines = CvData.parse_lines(cvdata)
  let article = null

  let l_hover = 0
  let l_focus = 0
  let hovered = []
  let focused = []

  $: if ($navigating && article) {
    cvmenu.deactivate()
    change_focus(0, 0, 0)
  }

  function handle_mouse({ target }, _index = l_hover) {
    if ($config.reader == 1) return // return if in zen mode

    let [nodes, lower, upper] = read_selection()
    const unchanged = !nodes

    switch (target.nodeName) {
      case 'CV-ITEM':
      case 'CV-MENU':
        return

      case 'CV-DATA':
        l_focus = _index
        hide_cvmenu()
        return

      case 'V-N':
      case 'Z-N':
        if (nodes) break

        nodes = [target]

        lower = +target.dataset.l
        upper = +target.dataset.u
        break

      default:
        if (!nodes) return
    }

    if (unchanged && target.classList.contains('focus')) {
      const dic = +target.dataset.d
      upsert.activate($input, dic == 3 || dic == 5 ? 0 : 1)
    } else {
      change_focus(_index, lower, upper, nodes)
    }
  }

  function change_focus(index, lower, upper, nodes) {
    l_focus = index

    focused.forEach((x) => x.classList.remove('focus'))
    hovered.forEach((x) => x.classList.remove('hover'))

    const line = article.querySelector(`#L${index}`)
    scroll_into_view(line, article, 'smooth')

    if (!nodes) {
      let child = line.querySelector(`v-n[data-l="${lower}"]`)

      if (upper == 0 && child && +child.dataset.d < 2) {
        const dnode = line.querySelector('v-n:not([data-d="1"])')
        if (dnode) child = dnode
      }

      if (child) {
        nodes = [child]
        lower = +child.dataset.l
        upper = +child.dataset.u
      } else {
        nodes = []
      }
    }

    focused = nodes
    input.put([zhtext[index], lower, upper])
    if ($lookup.enabled || $lookup.actived) {
      lookup.activate($input, $lookup.enabled)
    }

    if (nodes.length > 0) {
      focused.forEach((x) => x.classList.add('focus'))
      cvmenu.activate(nodes, article)
    }

    hovered = []

    const query_all = (query) => Array.from(line.querySelectorAll(query))

    for (let i = lower; i < upper; i++) {
      hovered = hovered.concat(query_all(`[data-l="${i}"]`))
      hovered = hovered.concat(query_all(`[data-u="${i + 1}"]`))
    }

    hovered.forEach((x) => x.classList.add('hover'))
  }

  function retake_control() {
    if (!article) return
    article.focus()
    change_focus(l_focus, $input.lower, $input.upper)
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
        focus = (focus - 1 + zhtext.length) % zhtext.length
        return change_focus(focus, 0, 0)

      case 'ArrowDown':
        event.preventDefault()
        focus = (focus + 1) % zhtext.length
        return change_focus(focus, 0, 0)

      case 'ArrowLeft':
        event.preventDefault()
        const prev = prev_elem(focused[0])

        if (!prev) {
          let step = 4

          while (step > 0) {
            focus = (focus - 1 + zhtext.length) % zhtext.length

            let node = article.querySelector(`#L${focus}`)
            while (node && node.nodeName != 'V-N') {
              node = node.lastChild
              while (node && node.nodeType != 1) node = node.previousSibling
              // console.log(node)
            }

            if (node) {
              while (+node.dataset.d < 2) {
                const prev = prev_elem(node)
                if (prev) node = prev
                else break
              }

              const lower = +node.dataset.l
              const upper = +node.dataset.u
              return change_focus(focus, lower, upper, [node])
            }

            step -= 1
          }

          return
        }

        if (event.shiftKey) {
          focused.unshift(prev)
          const lower = +prev.dataset.l
          return change_focus(l_focus, lower, $input.upper, focused)
        } else {
          const lower = +prev.dataset.l
          const upper = +prev.dataset.u
          return change_focus(l_focus, lower, upper, [prev])
        }

      case 'ArrowRight':
        event.preventDefault()
        const next = next_elem(focused[focused.length - 1])

        if (!next) {
          focus = (focus + 1) % zhtext.length
          return change_focus(focus, 0, 1)
        }

        if (event.shiftKey) {
          const nodes = focused.concat([next])
          const upper = +next.dataset.u
          return change_focus(l_focus, $input.lower, upper, nodes)
        } else {
          const lower = +next.dataset.l
          const upper = +next.dataset.u
          return change_focus(l_focus, lower, upper, [next])
        }
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
    padding: 0 var(--pad);
    color: var(--fgcolor, #{color(gray, 8)});
    @include bdradi();
    @include tm-dark { --fgcolor: #{color(gray, 3)}; }

    :global(.app-ff-1) & { font-family: var(--font-sans); }
    :global(.app-ff-2) & { font-family: var(--font-serif); }
    :global(.app-ff-3) & { font-family: Nunito Sans, var(--font-sans); }
    :global(.app-ff-4) & { font-family: Lora, var(--font-serif); }

    &.focus {
      :global(.tm-light) & { @include bgcolor(warning, 2, 1); }
      :global(.tm-warm) & { @include bgcolor(warning, 0, 4); }
      :global(.tm-dark) & { @include bgcolor(neutral, 8, 9); }
      :global(.tm-oled) & { @include bgcolor(neutral, 9, 8); }
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
