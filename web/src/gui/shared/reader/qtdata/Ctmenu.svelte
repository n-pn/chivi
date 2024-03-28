<script context="module" lang="ts">
  import { writable } from 'svelte/store'

  import { get_client_rect } from '$utils/dom_utils'

  export const ctrl = {
    ...writable({ actived: false }),
    hide() {
      ctrl.set({ actived: false })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { Rdpage } from '$lib/reader'

  import { ctrl as lookup_ctrl } from '$gui/parts/SideLine.svelte'
  import { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

  export let rpage: Rdpage

  export async function show_vtform() {
    await rpage.load_hviet(1)
    vtform_ctrl.show()
  }

  export async function show_lookup(panel = '') {
    await rpage.load_hviet(1)
    lookup_ctrl.show(panel)
  }

  let p_top = 0
  let p_left = 0
  let p_mid = 0

  export function show_menu(parent: HTMLElement, on_focus: HTMLElement) {
    const parent_rect = parent.getBoundingClientRect()

    const { top, left, right } = get_client_rect(on_focus)

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

<div
  class="menu"
  class:_show={$ctrl.actived}
  on:blur={() => ctrl.hide()}
  style="--top: {p_top}px; --left: {p_left}px; --mid: {p_mid}px">
  <button
    class="btn"
    data-kbd="q"
    data-tip="Tra nghĩa từ"
    on:click|capture|stopPropagation={() => show_lookup('glossary')}>
    <SIcon name="search" />
  </button>

  <button
    class="btn"
    data-kbd="w"
    data-tip="Nhiều cách dịch"
    on:click|capture|stopPropagation={() => show_lookup('overview')}>
    <SIcon name="language" />
  </button>

  <button
    class="btn"
    data-kbd="↵"
    data-tip="Thêm sửa từ"
    on:click|capture|stopPropagation={() => show_vtform()}>
    <SIcon name="circle-plus" />
  </button>

  <button class="btn" data-kbd="=" data-tip="Sửa text gốc" disabled>
    <SIcon name="pencil" />
  </button>

  <button class="btn" data-kbd="-" data-tip="Báo lỗi dịch" disabled>
    <SIcon name="flag" />
  </button>
</div>

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

    // transition: all 0.05s ease-in-out;
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
