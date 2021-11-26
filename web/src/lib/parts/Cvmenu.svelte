<script context="module">
  import { writable } from 'svelte/store'
  import { create_input } from '$utils/create_stores'

  const width = 96

  export const input = create_input()

  export const ctrl = {
    ...writable({ actived: false, top: 0, left: 0 }),
    activate(target, parent) {
      const rect = get_rect(target)

      let left = Math.floor((rect.left + rect.right) / 2) - width / 2
      if (left < 0) left = 0
      else if (left + width > window.innerWidth)
        left = window.innerWidth - width

      const parent_rect = get_rect(parent)

      ctrl.set({
        actived: true,
        top: rect.bottom + 6 - parent_rect.top,
        left: left - parent_rect.left,
      })
    },
    deactivate: () => ctrl.set({ actived: false, top: 0, left: 0 }),
  }

  function get_rect(node) {
    const rects = node.getClientRects()
    return rects[rects.length - 1] || { left: 0, right: 0, bottom: 0, top: 0 }
  }
</script>

<script>
  import { ctrl as lookup } from '$parts/Lookup.svelte'
  import { ctrl as upsert } from '$parts/Upsert.svelte'
  import { ctrl as tlspec } from '$parts/Tlspec.svelte'

  import SIcon from '$atoms/SIcon.svelte'
</script>

<cv-menu style="--top: {$ctrl.top}px; --left: {$ctrl.left}px">
  <cv-item
    data-kbd="↵"
    data-tip="Sửa từ"
    tip-loc="bottom"
    on:click={() => upsert.activate($input, 0)}>
    <SIcon name="pencil" />
  </cv-item>

  <cv-item
    data-kbd="q"
    data-tip="Tra từ"
    tip-loc="bottom"
    on:click={() => lookup.activate($input, $lookup.enabled)}>
    <SIcon name="search" />
  </cv-item>

  <cv-item
    data-kbd="p"
    data-tip="Báo lỗi"
    tip-loc="bottom"
    on:click={() => tlspec.activate($input, true)}>
    <SIcon name="flag" />
  </cv-item>
</cv-menu>

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

    --bgc: #{color(primary, 6)};
    background: var(--bgc);

    @include bdradi();
    @include shadow();

    // prettier-ignore
    // @include tm-dark { --bgc: #{color(primary, 4)}; }

    &:before {
      display: block;
      position: absolute;
      content: ' ';
      bottom: 100%;
      left: 50%;
      margin-left: -0.375rem;

      border: 0.375rem solid transparent;
      border-bottom-color: var(--bgc);
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
