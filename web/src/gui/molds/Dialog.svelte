<script>
  import { scale, fade } from 'svelte/transition'
  import { backInOut } from 'svelte/easing'

  import { layers } from '$lib/stores'
  import SIcon from '$atoms/SIcon.svelte'

  export let actived = true
  export let on_close = () => {}
  export let _size = 'md'

  $: layers.toggle(actived, '.' + $$props.class)

  function hide_dialog() {
    actived = false
    on_close(false) // false mean nothing changed
  }
</script>

<dialog-wrap on:click={hide_dialog} transition:fade={{ duration: 100 }}>
  <dialog-body
    tabindex="-1"
    class="{$$props.class} _{_size}"
    on:click={(e) => e.stopPropagation()}
    transition:scale={{ duration: 100, easing: backInOut }}>
    {#if $$slots.header}
      <dialog-head>
        <slot name="header" />
        <button
          type="button"
          class="x-btn"
          data-kbd="esc"
          on:click={hide_dialog}>
          <SIcon name="x" />
        </button>
      </dialog-head>
    {/if}

    <slot />
  </dialog-body>
</dialog-wrap>

<style lang="scss">
  dialog-wrap {
    @include flex-ca;
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: var(--z-idx, 60);
    background: rgba(#000, 0.75);
  }

  dialog-head {
    @include flex-cx;
    padding: 0.25rem 0.5rem;
  }

  .x-btn {
    margin-left: auto;
    padding: 0 0.125rem;
    background: none;

    @include fgcolor(tert);
    // prettier-ignore
    &:hover { @include fgcolor(primary, 6); }
  }

  $dialog-widths: (
    xs: 20rem,
    sm: 24rem,
    md: 28rem,
    lg: 32rem,
    xl: 36rem,
  );

  dialog-body {
    display: block;
    width: 50vw;
    max-width: 100%;

    @include bgcolor(secd);

    @include shadow(1);
    @include darksd();

    // prettier-ignore
    @each $style, $width in $dialog-widths {
      &._#{$style} {
        width: $width;
        @media (min-width: $width) { @include bdradi(); }
      }
    }

    &.upsert {
      @include bgcolor(tert);
    }
  }
</style>
