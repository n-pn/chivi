<script context="module">
  import { writable } from 'svelte/store'
  import { create_input } from '$utils/create_stores'
  import { get_client_rect } from '$utils/dom_utils'

  export const input = create_input()

  export const ctrl = {
    ...writable({ actived: false, top: 0, left: 0 }),
    activate(nodes, parent) {
      const { top, left } = get_client_rect(nodes[0])
      const { right } = get_client_rect(nodes[nodes.length - 1])

      const width = 100

      let out_left = Math.floor((left + right) / 2) - width / 2

      if (out_left < 0) out_left = 0
      else if (out_left + width > window.innerWidth)
        out_left = window.innerWidth - width

      const parent_rect = parent.getBoundingClientRect()

      ctrl.set({
        actived: true,
        top: top - parent_rect.top - 40,
        left: out_left - parent_rect.left,
      })
    },
    deactivate() {
      ctrl.set({ actived: false, top: 0, left: 0 })
    },
  }
</script>

<script>
  import { ctrl as lookup } from '$parts/Lookup.svelte'
  import { ctrl as upsert } from '$parts/Upsert.svelte'
  import { ctrl as tlspec } from '$parts/Tlspec.svelte'

  import SIcon from '$atoms/SIcon.svelte'
</script>

{#if $ctrl.actived}
  <cv-menu style="--top: {$ctrl.top}px; --left: {$ctrl.left}px">
    <cv-item
      data-kbd="x"
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
