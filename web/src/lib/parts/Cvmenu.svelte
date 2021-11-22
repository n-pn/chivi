<script context="module">
  import { writable } from 'svelte/store'
  export const state = writable(0)
  export const place = writable([100, 100])
  export const input = writable([''])

  import { activate as lookup_activate } from '$parts/Lookup.svelte'
  import { activate as upsert_activate } from '$parts/Upsert.svelte'

  import { state as tlspec_state } from '$parts/Tlspec.svelte'

  const width = 96

  export function activate(target, parent) {
    const rect = get_rect(target)

    let left = Math.floor((rect.left + rect.right) / 2) - width / 2
    if (left < 0) left = 0
    else if (left + width > window.innerWidth) left = window.innerWidth - width

    const parent_rect = get_rect(parent)

    place.set([rect.bottom + 6 - parent_rect.top, left - parent_rect.left])
    state.set(1)
  }

  function get_rect(node) {
    const rects = node.getClientRects()
    return rects[rects.length - 1]
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  $: [top, left] = $place

  // $: if (cvmenu && $state) cvmenu.focus()
</script>

<cvmenu-wrap
  tabindex="-1"
  on:blur={() => state.set(0)}
  style="--top: {top}px; --left: {left}px">
  <cvmenu-item
    data-kbd="↵"
    data-tip="Sửa từ"
    tip-loc="bottom"
    on:click={() => upsert_activate($input, 0)}>
    <SIcon name="pencil" />
  </cvmenu-item>

  <cvmenu-item
    data-kbd="q"
    data-tip="Tra từ"
    tip-loc="bottom"
    on:click={() => lookup_activate($input)}>
    <SIcon name="search" />
  </cvmenu-item>

  <cvmenu-item
    data-kbd="p"
    data-tip="Báo lỗi"
    tip-loc="bottom"
    on:click={() => ($tlspec_state = 1)}>
    <SIcon name="flag" />
  </cvmenu-item>
</cvmenu-wrap>

<style lang="scss">
  $size: 2rem;

  cvmenu-wrap {
    height: $size;
    z-index: 9;
    display: flex;
    position: absolute;
    height: $size;
    width: 6rem;
    padding: 0 0.25rem;

    top: var(--top, 20vw);
    left: var(--left, 20vw);
    @include fgcolor(white);
    @include bgcolor(black);
    @include bdradi();
    @include shadow();

    &:before {
      display: block;
      position: absolute;
      content: ' ';
      bottom: 100%;
      left: 50%;
      margin-left: -0.375rem;

      border: 0.375rem solid transparent;
      border-bottom-color: color(black);
    }
  }

  cvmenu-item {
    width: $size;
    height: 100%;
    @include flex-ca;

    &:hover {
      cursor: pointer;
      @include fgcolor(primary, 5);
    }
  }
</style>
