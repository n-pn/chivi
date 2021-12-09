<script context="module">
  import { onMount, onDestroy } from 'svelte'
  import { writable } from 'svelte/store'
  import { ztext, zfrom, zupto } from '$lib/stores'

  import {
    scroll_into_view,
    get_client_rect,
    read_selection,
    next_elem,
    prev_elem,
  } from '$utils/dom_utils'

  const hovered = []
  const focused = []

  export const ctrl = {
    ...writable({ actived: false, top: 0, left: 0 }),
    hide() {
      update_hovered()
      update_focused()
      ctrl.set({ actived: false, top: 0, left: 0 })
    },
  }

  function update_hovered(line, from = 0, upto = 0) {
    hovered.forEach((x) => x?.classList.remove('hover'))
    hovered.length = 0

    if (!line) return

    const add_hover = (query) => {
      for (let node of line.querySelectorAll(query)) {
        node.classList.add('hover')
        hovered.push(node)
      }
    }

    for (let i = from; i < upto; i++) {
      add_hover(`[data-l="${i}"]`)
      add_hover(`[data-u="${i + 1}"]`)
    }
  }

  function update_focused(data = []) {
    focused.forEach((x) => x?.classList.remove('focus'))
    focused.length = 0

    data.forEach((x) => {
      x.classList.add('focus')
      focused.push(x)
    })
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  import Lookup, { ctrl as lookup } from '$parts/Lookup.svelte'
  import Upsert, { ctrl as upsert } from '$parts/Upsert.svelte'
  import Tlspec, { ctrl as tlspec } from '$parts/Tlspec.svelte'

  export let article

  export let lines
  export let l_focus
  export let l_hover

  export let on_change = () => {}

  const on_destroy = () => {
    article.focus()
    change_focus(null, l_focus)
  }

  onMount(() => {
    setTimeout(() => article.addEventListener('mouseup', handle_mouse), 50)
  })
  onDestroy(() => article.removeEventListener('mouseup', handle_mouse))

  function handle_mouse({ target, which }) {
    if (which == 3) return // return if is right click
    let nodes = read_selection()

    switch (target.nodeName) {
      case 'V-N':
      case 'Z-N':
        if (nodes) break
        nodes = focused.includes(target) ? [...focused] : [target]
        break

      case 'CV-DATA':
      // if (nodes) break

      case 'ARTICLE':
        ctrl.hide()

      default:
        return
    }

    change_focus(nodes, l_hover, target)
  }

  function handle_keydown(event) {
    if (article != document.activeElement) return

    switch (event.key) {
      case 'Escape':
        ctrl.hide()
        return

      case 'Enter':
        event.preventDefault()
        const dic = focused.length == 1 && +focused[0].dataset.d % 2 ? 0 : 1
        return setTimeout(() => upsert.show(dic), 20)

      case 'ArrowUp':
        event.preventDefault()
        return change_focus(null, (l_focus - 1 + lines.length) % lines.length)

      case 'ArrowDown':
        event.preventDefault()
        return change_focus(null, (l_focus = (l_focus + 1) % lines.length))

      case 'ArrowLeft':
        event.preventDefault()
        return move_left(event.shiftKey)

      case 'ArrowRight':
        event.preventDefault()
        return move_right(event.shiftKey)
    }
  }

  function find_nearest_nodes(line, idx, max) {
    if (idx >= max) idx = max - 1

    let fallback

    for (let i = idx; i < max; i++) {
      const elem = line.querySelector(`v-n[data-l="${i}"]`)
      if (!elem) continue
      if (+elem.dataset.d > 0) return [elem]
      else fallback = elem
    }

    for (let i = idx; i >= 0; i--) {
      const elem = line.querySelector(`v-n[data-l="${i}"]`)
      if (!elem) continue
      if (+elem.dataset.d > 0) return [elem]
      else fallback = fallback || elem
    }

    return fallback ? [fallback] : []
  }

  function change_focus(nodes, index, target = null) {
    if (index != l_focus) {
      l_focus = index
      $ztext = lines[index]
    }

    const line = article.querySelector(`#L${index}`)
    if (line) scroll_into_view(line, article, 'smooth')

    if (!nodes) nodes = find_nearest_nodes(line, $zfrom, $ztext.length)
    if (nodes.length == 0) return

    $zfrom = +nodes[0].dataset.l
    $zupto = +nodes[nodes.length - 1].dataset.u
    lookup.show(false)

    if (target && focused.includes(target)) {
      upsert.show(nodes.length == 1 && +target.dataset.d % 2 == 0 ? 1 : 0)
    } else {
      update_hovered(line, $zfrom, $zupto)
      update_focused(nodes)
      show_cvmenu(nodes)
    }
  }

  function move_left(shift = false) {
    if (focused.length == 0) change_focus(null, l_focus)
    let node = prev_elem(focused[0], true)

    let max_scan = 3
    let focus = l_focus

    while (!node && max_scan-- > 0) {
      focus = (focus - 1 + lines.length) % lines.length
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

    $zfrom = +nodes[0].dataset.l
    $zupto = shift ? $zupto : +nodes[0].dataset.u

    return change_focus(nodes, focus)
  }

  function can_skip(node) {
    return node ? +node.dataset.d < 1 : false
  }

  function move_right(shift = false) {
    if (focused.length == 0) change_focus(null, l_focus)
    let node = next_elem(focused[focused.length - 1], true)

    let max_scan = 3
    let focus = l_focus

    while (!node && max_scan > 0) {
      max_scan -= 1

      focus = (focus + 1) % lines.length
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

    $zfrom = shift ? $zfrom : +nodes[nodes.length - 1].dataset.l
    $zupto = +nodes[nodes.length - 1].dataset.u

    return change_focus(nodes, focus)
  }

  function show_cvmenu(nodes) {
    const parent_rect = article.getBoundingClientRect()

    const { top, left } = get_client_rect(nodes[0])
    const { right } = get_client_rect(nodes[nodes.length - 1])

    const width = 100

    let out_left = Math.floor((left + right) / 2) - width / 2

    if (out_left < 0) out_left = 0
    else if (out_left + width > window.innerWidth)
      out_left = window.innerWidth - width

    ctrl.set({
      actived: true,
      top: top - parent_rect.top - 40,
      left: out_left - parent_rect.left,
    })
  }
  // $: console.log($input)
</script>

<svelte:window on:keydown={handle_keydown} />

{#if $ctrl.actived}
  <cv-menu style="--top: {$ctrl.top}px; --left: {$ctrl.left}px">
    <cv-item
      data-kbd="q"
      data-tip="Tra từ"
      tip-loc="bottom"
      on:click|capture={lookup.show}>
      <SIcon name="search" />
    </cv-item>

    <cv-item
      data-kbd="x"
      data-tip="Sửa từ"
      tip-loc="bottom"
      on:click|capture={() => upsert.show(0)}>
      <SIcon name="pencil" />
    </cv-item>

    <cv-item
      data-kbd="p"
      data-tip="Báo lỗi"
      tip-loc="bottom"
      on:click|capture={tlspec.show}>
      <SIcon name="flag" />
    </cv-item>
  </cv-menu>
{/if}

<div hidden>
  <button data-kbd="c" on:click={() => upsert.show(1)}>C</button>
</div>

{#if $lookup.enabled || $lookup.actived}
  <Lookup {on_destroy} />
{/if}

{#if $upsert.state > 0}
  <Upsert {on_change} {on_destroy} />
{/if}

{#if $tlspec.actived}
  <Tlspec {on_destroy} />
{/if}

<style lang="scss">
  $size: 2rem;

  cv-menu {
    height: $size;
    z-index: 40;
    display: flex;
    position: absolute;
    height: $size;
    width: 6rem;
    padding: 0 0.25rem;

    top: var(--top, 20vw);
    left: var(--left, 20vw);

    --bgc: #{color(primary, 6, 9.5)};
    background: var(--bgc);

    @include bdradi();
    @include shadow();

    // prettier-ignore
    // @include tm-dark { --bgc: #{color(primary, 4)}; }

    &:before {
      display: block;
      position: absolute;
      content: ' ';
      top: 100%;
      left: 50%;
      margin-left: -0.375rem;

      border: 0.375rem solid transparent;
      border-top-color: var(--bgc);
    }
  }

  cv-item {
    @include flex-ca;
    cursor: pointer;
    width: $size;
    height: 100%;
    @include fgcolor(white);

    // prettier-ignore
    &:hover { @include fgcolor(primary, 2); }
  }
</style>
