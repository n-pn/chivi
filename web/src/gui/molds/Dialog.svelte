<script lang="ts">
  import { scale, fade } from 'svelte/transition'
  import { backInOut } from 'svelte/easing'

  import { layers } from '$lib/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let actived = true
  export let on_close = (_?: any) => {}
  export let _size = 'md'

  $: layers.toggle(actived, '.' + $$props.class)
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div class="wrap" on:click={() => on_close(false)} in:fade={{ duration: 100 }}>
  <div
    class="main {$$props.class} _{_size}"
    on:click={(e) => e.stopPropagation()}
    in:scale={{ duration: 100, easing: backInOut }}>
    {#if $$slots.header}
      <header class="head">
        <slot name="header" />
        <button
          type="button"
          class="x-btn"
          data-kbd="esc"
          on:click={() => on_close(false)}>
          <SIcon name="x" />
        </button>
      </header>
    {/if}

    <section class="dialog-body">
      <slot />
    </section>
  </div>
</div>

<style lang="scss">
  .wrap {
    @include flex-ca;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    width: 100vw;
    height: 100vh;
    height: 100svh;
    z-index: var(--z-idx, 60);
    background: rgba(#000, 0.75);
  }

  .head {
    @include flex-cx;

    height: 2.25rem;
    line-height: 2.25rem;
    padding-left: 0.75rem;
    font-weight: 500;
    @include border(--bd-main, $loc: bottom);
    @include fgcolor(secd);
  }

  .x-btn {
    @include flex-ca;
    width: 2.25rem;
    height: 2.25rem;
    margin-left: auto;
    background: transparent;

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

  .main {
    width: 50vw;
    max-width: 100%;

    @include bgcolor(tert);
    @include shadow(1);
    @include darksd();

    // prettier-ignore
    @each $style, $width in $dialog-widths {
      &._#{$style} {
        width: $width;
        @media (min-width: $width) { @include bdradi(); }
      }
    }

    &.upsert,
    &.postag {
      @include bgcolor(tert);
    }
  }
</style>
