<script lang="ts">
  import { navigating } from '$app/stores'
  import { toleft, layers } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let actived = false
  export let sticked = false

  export let _sticky = false
  export let _slider = 'right'

  $: $toleft = sticked && actived

  $: if ($navigating) actived = false

  $: klass = $$props.class || 'slider'

  $: layers.toggle(actived, '.' + klass)

  const hide_slider = () => {
    actived = false
    $toleft = false
    layers.remove('.' + klass)
  }
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="slider-wrap"
  class:_active={actived}
  class:_sticky={sticked}
  on:click={hide_slider}>
</div>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="slider-main {klass}"
  class:_left={_slider == 'left'}
  class:_right={_slider == 'right'}
  class:_active={actived}>
  <header class="head">
    <slot name="header-left" />
    <slot name="header-right" />

    {#if _sticky}
      <button
        class="-btn"
        class:_active={sticked}
        on:click={() => (sticked = !sticked)}>
        <SIcon name="pin" />
      </button>
    {/if}

    <button
      class="-btn"
      data-kbd="esc"
      on:click={hide_slider}
      data-tip="Đóng"
      data-tip-loc="bottom">
      <SIcon name="x" />
    </button>
  </header>

  <section class="body">
    <slot />
  </section>

  <slot name="foot" />
</div>

<style lang="scss">
  .slider-wrap {
    position: fixed;
    display: block;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 50;

    background-color: rgba(#000, 0.6);
    // transition: background-color 0.5s ease-in-out;

    // prettier-ignore
    // @media (prefers-reduced-motion) { transition: none; }

    visibility: hidden;
    // prettier-ignore
    &._active { visibility: visible; }

    &._sticky {
      pointer-events: none;
      background: transparent;
    }
  }

  .slider-main {
    position: fixed;

    top: 0;
    bottom: 0;
    width: var(--slider-width, 25rem);
    max-width: calc(100vw - 1.5rem);

    display: flex;
    flex-direction: column;

    // height: 100vh;
    z-index: 55;

    background: var(--bg-secd);
    @include shadow(2);
    // @include transition();

    &._left {
      right: 100%;
      // prettier-ignore
      &._active { transform: translateX(100%); }
    }

    &._right {
      left: 100%;
      // prettier-ignore
      &._active { transform: translateX(-100%); }
    }
  }

  // @keyframes slide-in {
  //   100% {
  //     transform: translateX(0);
  //   }
  // }

  $hd-height: 3rem;
  $hd-line-height: 2.25rem;

  .head {
    display: flex;

    height: $hd-height;
    line-height: $hd-line-height;
    padding: 0.375rem 0.5rem;

    @include border($loc: bottom);
    @include shadow(1);
    @include fgcolor(tert);
    @include bgcolor(secd);

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
      margin-top: -0.125rem;
    }

    :global(.-text) {
      flex-grow: 1;
      font-weight: 500;
      margin-left: 0.25rem;
      text-transform: uppercase;
      @include ftsize(md);
    }

    :global(.-btn) {
      padding: 0 0.5rem;

      color: inherit;
      background: inherit;

      @include bdradi;

      &:hover {
        @include fgcolor(primary, 5);
        @include bgcolor(main);
      }
    }

    :global(.-btn._active) {
      @include fgcolor(primary, 5);
      @include bgcolor(main);
    }
  }

  .body {
    flex: 1;
    @include scroll;
  }
</style>
