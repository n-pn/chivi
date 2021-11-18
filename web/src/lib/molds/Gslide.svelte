<script>
  import { navigating } from '$app/stores'
  import { toleft, add_layer, remove_layer } from '$lib/stores'

  import SIcon from '$atoms/SIcon.svelte'

  export let actived = false

  export let _klass = 'slider'
  export let _sticky = false
  export let _slider = 'right'
  export let _rwidth = 25

  let sticked = false

  $: $toleft = sticked
  $: if ($navigating) actived = false

  $: actived ? add_layer('.' + _klass) : remove_layer('.' + _klass)
</script>

<slider-wrap
  class:_active={actived}
  class:_sticky={sticked}
  on:click={() => (actived = false)} />

<slider-main
  class={_klass}
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

    <button class="-btn" data-kbd="esc" on:click={() => (actived = false)}>
      <SIcon name="x" />
    </button>
  </header>

  <section class="body">
    <slot />
  </section>
</slider-main>

<style lang="scss">
  slider-wrap {
    position: fixed;
    display: block;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 50;

    background-color: rgba(#000, 0.5);
    transition: background-color 0.5s ease-in-out;

    // prettier-ignore
    @media (prefers-reduced-motion) { transition: none; }

    visibility: hidden;
    // prettier-ignore
    &._active { visibility: visible; }

    &._sticky {
      pointer-events: none;
      background: transparent;
    }
  }

  slider-main {
    position: fixed;
    display: block;

    top: 0;
    width: var(--width, 20rem);
    overflow-y: auto;
    max-width: calc(100vw - 1.5rem);
    height: 100vh;
    z-index: 55;

    will-change: transform;
    transition: transform 0.1s ease-in-out;

    // prettier-ignore
    @media (prefers-reduced-motion) { transition: none; }

    background: var(--bg-secd);
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
    z-index: 1002;

    @include fgcolor(tert);
    @include bgcolor(secd);

    height: $hd-height;
    line-height: $hd-line-height;
    padding: 0.375rem 0.5rem;

    border-bottom: 1px solid var(--bd-main);
    @include shadow(1);

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
      margin-top: -0.125rem;
    }

    :global(.-text) {
      flex-grow: 1;
      font-weight: 500;
      margin-left: 0.5rem;
      text-transform: uppercase;
      @include ftsize(md);
    }

    :global(.-btn) {
      padding: 0 0.5rem;

      @include bdradi;
      color: inherit;
      background: transparent;

      &:hover,
      &._active {
        @include fgcolor(primary, 5);
        @include bgcolor(main);
      }
    }
  }

  .body {
    display: flex;
    flex-direction: column;
  }
</style>
