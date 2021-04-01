<script>
  import SIcon from '$lib/blocks/SIcon'
  export let actived = false
  export let sticked = false

  export let _sticky = false
  export let _slider = 'right'
  export let _rwidth = 25

  function handle_keydown(evt) {
    if (!actived) return
    evt.stopPropagation()
    if (evt.keyCode == 27) actived = false
  }
</script>

<svelte:window on:keydown={handle_keydown} />

{#if actived && !sticked}
  <div class="holder" on:click={() => (actived = false)} />
{/if}

<aside
  class="slider"
  class:_left={_slider == 'left'}
  class:_right={_slider == 'right'}
  class:_active={actived}
  style="--width: {_rwidth}rem;">
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

    <button class="-btn" on:click={() => (actived = false)}>
      <SIcon name="x" />
    </button>
  </header>

  <section class="body">
    <slot />
  </section>
</aside>

<style lang="scss">
  .holder {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 1000;
    background: rgba(#000, 0.5);

    transition: background 0.5s ease-in-out;
    @media (prefers-reduced-motion) {
      transition: none;
    }
  }

  .slider {
    position: fixed;

    top: 0;
    width: var(--width);
    max-width: 90vw;
    height: 100%;
    z-index: 1001;

    will-change: transform;
    transition: transform 0.1s ease-in-out;
    @media (prefers-reduced-motion) {
      transition: none;
    }

    @include bgcolor(white);
    @include shadow(2);

    &._left {
      left: 0;
      transform: translateX(-100%);
    }

    &._right {
      right: 0;
      transform: translateX(100%);
    }

    &._active {
      // animation: slide-in 0.1s forwards;
      transform: translateX(0);
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
    position: sticky;

    top: 0;
    z-index: 1;

    height: $hd-height;
    line-height: $hd-line-height;
    padding: 0.375rem 0.75rem;
    border-bottom: 1px solid color(neutral, 3);
    @include fgcolor(neutral, 6);
    @include shadow(1);

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
      margin-top: -0.125rem;
    }

    :global(& .-text) {
      flex-grow: 1;
      font-weight: 500;
      margin-left: 0.5rem;
      text-transform: uppercase;
      @include font-size(3);
    }

    :global(& .-btn) {
      padding: 0 0.5rem;
      @include radius;
      @include fgcolor(neutral, 6);
      @include bgcolor(transparent);

      &:hover {
        @include fgcolor(primary, 6);
        @include bgcolor(neutral, 2);
      }

      &._active {
        @include fgcolor(primary, 6);
        @include bgcolor(neutral, 2);
      }
    }
  }

  .body {
    flex: 1;
    overflow-y: auto;
  }
</style>
