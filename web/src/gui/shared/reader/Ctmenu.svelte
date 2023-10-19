<script context="module" lang="ts">
  import { onMount } from 'svelte'
  import { writable } from 'svelte/store'
  // import { ztext, zfrom, zupto } from '$lib/stores'

  import {
    scroll_into_view,
    get_client_rect,
    read_selection,
    next_elem,
    prev_elem,
  } from '$utils/dom_utils'

  const hovered: HTMLElement[] = []
  const focused: HTMLElement[] = []

  export const ctrl = {
    ...writable({ actived: false }),
    hide() {
      ctrl.set({ actived: false })
      update_focused()
      update_hovered()
    },
  }

  function update_hovered(line?: HTMLElement, from = 0, upto = 0) {
    hovered.forEach((x) => x?.classList.remove('hover'))
    hovered.length = 0

    if (!line) return

    const add_hover = (query: string) => {
      line.querySelectorAll(query).forEach((node) => {
        node.classList.add('hover')
        hovered.push(node as HTMLElement)
      })
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

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import { ctrl as lookup } from '$gui/parts/Lookup.svelte'
  import { ctrl as upsert } from '$gui/parts/Upsert.svelte'

  export let article: HTMLElement
  export let fix_raw = false

  export let lines: string[]
  export let l_focus: number
  export let l_hover: number

  export let on_change = () => {}

  const on_destroy = () => {
    article.focus()
    const nodes = []

    const elem = article.querySelector(`#L${l_focus}`)
    for (let lower = $zfrom; lower < $zupto; lower++) {
      const node = elem.querySelector(`v-n[data-l="${lower}"]`)
      if (node) nodes.push(node)
    }
    change_focus(nodes, l_focus)
  }

  onMount(() => {
    setTimeout(() => article.addEventListener('mouseup', handle_mouse), 40)
    return () => article?.removeEventListener('mouseup', handle_mouse)
  })

  function handle_mouse({ target, which }) {
    if (which == 3 || fix_raw) return // return if is right click
    let nodes = read_selection()

    switch (target.nodeName) {
      case 'V-N':
      case 'Z-N':
        if (nodes) break
        nodes = focused.includes(target) ? [...focused] : [target]
        break

      case 'ARTICLE':
      case 'H1':
      case 'P':
        if (!nodes) ctrl.hide()

      default:
        return
    }

    change_focus(nodes as HTMLElement[], l_hover, target)
  }

  function handle_keydown(event: KeyboardEvent) {
    if (!$ctrl.actived) return

    switch (event.key) {
      case 'Escape':
        ctrl.hide()
        return

      case 'ArrowUp':
        if (!event.ctrlKey) return

        event.preventDefault()
        return change_focus(null, (l_focus - 1 + lines.length) % lines.length)

      case 'ArrowDown':
        if (!event.ctrlKey) return

        event.preventDefault()
        return change_focus(null, (l_focus = (l_focus + 1) % lines.length))

      case 'ArrowLeft':
        if (!event.ctrlKey) return

        event.preventDefault()
        return move_left(event.shiftKey)

      case 'ArrowRight':
        if (!event.ctrlKey) return

        event.preventDefault()
        return move_right(event.shiftKey)
    }
  }

  const show_upsert = (_no_guess = true) => setTimeout(() => upsert.show(0), 20)

  function find_nearest_nodes(line: HTMLElement, idx: number, max: number) {
    if (idx >= max) idx = max - 1

    let fallback: HTMLElement

    for (let i = idx; i < max; i++) {
      const elem = line.querySelector(`v-n[data-l="${i}"]`)
      if (!(elem instanceof HTMLElement)) continue

      if (+elem.dataset.d > 0) return [elem]
      else fallback = elem
    }

    for (let i = idx; i >= 0; i--) {
      const elem = line.querySelector(`v-n[data-l="${i}"]`)
      if (!(elem instanceof HTMLElement)) continue

      if (+elem.dataset.d > 0) return [elem]
      else fallback = fallback || elem
    }

    return fallback ? [fallback] : []
  }

  let timeout: number

  function change_focus(
    nodes: HTMLElement[],
    index: number,
    target = null,
    delay = 0
  ) {
    if (index != l_focus) l_focus = index
    $ztext = lines[index]

    const line = article.querySelector(`#L${index}`) as HTMLElement | null
    if (line) scroll_into_view(line, article, 'smooth')

    if (!nodes) nodes = find_nearest_nodes(line, $zfrom, $ztext.length)
    if (nodes.length == 0) return

    let from = +nodes[0].dataset.l
    let upto = +nodes[0].dataset.u

    for (let i = 1; i < nodes.length; i++) {
      const lower = +nodes[i].dataset.l
      const upper = +nodes[i].dataset.u
      if (lower < from) from = lower
      if (upper > upto) upto = upper
    }

    $zfrom = from
    $zupto = upto
    lookup.show(false)

    if (target && focused.includes(target)) {
      show_upsert(false)
    } else {
      update_hovered(line, $zfrom, $zupto)
      update_focused(nodes)

      if (timeout) window.clearTimeout(timeout)
      timeout = window.setTimeout(() => show_cvmenu(nodes), delay)
    }
  }

  function move_left(shift = false, delay = 0) {
    if (focused.length == 0) change_focus(null, l_focus, null, 1000)
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

    return change_focus(nodes, focus, null, delay)
  }

  function can_skip(node: HTMLElement | null) {
    return node ? +node.dataset.d < 1 : false
  }

  function move_right(shift = false, delay = 0) {
    if (focused.length == 0) change_focus(null, l_focus, null, 500)
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

    return change_focus(nodes, focus, null, delay)
  }

  let p_top = 0
  let p_left = 0
  let p_mid = 0

  function show_cvmenu(nodes: HTMLElement[]) {
    const parent_rect = article.getBoundingClientRect()

    const { top, left } = get_client_rect(nodes[0])
    const { right } = get_client_rect(nodes[nodes.length - 1])

    const width = 150

    p_mid = width / 2
    let out_left = Math.floor((left + right) / 2) - width / 2

    const window_width = document.body.clientWidth

    if (out_left < 4) {
      p_mid = p_mid - 4 + out_left
      out_left = 4
    } else if (out_left > window_width - width - 4) {
      p_mid = p_mid + 4 - window_width + width + out_left
      out_left = window_width - width - 4
    }

    p_top = top - parent_rect.top - 44
    p_left = out_left - parent_rect.left

    ctrl.set({ actived: true })
  }
</script>

<svelte:window on:keydown={handle_keydown} />

<div
  class="menu"
  class:_show={$ctrl.actived}
  style="--top: {p_top}px; --left: {p_left}px; --mid: {p_mid}px">
  <button
    class="btn"
    data-kbd="⇧←"
    data-tip="Mở sang trái"
    on:click|capture|stopPropagation={() => move_left(true, 500)}>
    <SIcon name="arrow-left-square" />
  </button>

  <button
    class="btn"
    data-kbd="&bsol;"
    data-key="Backslash"
    data-tip="Tra từ"
    on:click|capture|stopPropagation={() => lookup.show(true)}>
    <SIcon name="search" />
  </button>

  <button
    class="btn"
    data-kbd="↵"
    data-tip="Thêm sửa từ"
    on:click|capture|stopPropagation={() => show_upsert()}>
    <SIcon name="circle-plus" />
  </button>

  <button
    class="btn"
    data-kbd="-"
    data-tip="Sửa text gốc"
    on:click|capture|stopPropagation={() => (fix_raw = true)}>
    <SIcon name="edit" />
  </button>

  <button
    class="btn"
    data-kbd="⇧→"
    data-tip="Mở sang phải"
    on:click|capture|stopPropagation={() => move_right(true, 500)}>
    <SIcon name="arrow-right-square" />
  </button>
</div>

{#if $lookup.enabled || $lookup.actived}<Lookup {on_destroy} />{/if}
{#if $upsert.state > 0}<Upsert {on_change} {on_destroy} />{/if}

<style lang="scss">
  $width: 1.875rem;
  $height: 2.25rem;

  .menu {
    display: none;

    height: $height;
    z-index: 40;
    position: absolute;
    width: $width * 5;
    padding: 0;

    top: var(--top, 20vw);
    left: var(--left, 20vw);

    --bgc: #{color(primary, 6, 9.5)};
    background: var(--bgc);

    @include bdradi();
    @include shadow();

    transition: all 0.05s ease-in-out;
    // prettier-ignore
    // @include tm-dark { --bgc: #{color(primary, 4)}; }

    &._show {
      @include flex();
    }

    &:before {
      display: block;
      position: absolute;
      content: ' ';
      top: 100%;
      // left: 50%;
      left: var(--mid);
      margin-left: -0.375rem;

      border: 0.375rem solid transparent;
      border-top-color: var(--bgc);
    }
  }

  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;

    height: 100%;
    flex: 1;

    background: none;
    @include fgcolor(white);

    &:hover {
      @include fgcolor(primary, 2);
    }
    &:first-child {
      @include bdradi($loc: left);
    }
    &:last-child {
      @include bdradi($loc: right);
    }
  }
</style>
