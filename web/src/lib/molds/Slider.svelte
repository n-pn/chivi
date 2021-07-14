<script>
  import SIcon from '$atoms/SIcon.svelte'
  export let actived = false
  export let sticked = false

  export let _sticky = false
  export let _slider = 'right'
  export let _rwidth = 25

  function hide_if_anchor_clicked(e) {
    if (e.target.tagName == 'A') actived = false
  }
</script>

<div
  class="wrap"
  class:_active={actived}
  class:_sticky={sticked}
  on:click={() => (actived = false)} />

<aside
  class="main"
  class:_left={_slider == 'left'}
  class:_right={_slider == 'right'}
  class:_active={actived}
  on:click={hide_if_anchor_clicked}
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
</aside>

<style lang="scss">
  .wrap {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 1000;

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

  .main {
    position: fixed;

    top: 0;
    width: var(--width, 20rem);
    overflow-y: auto;
    max-width: 90vw;
    height: 100vh;
    z-index: 1001;

    will-change: transform;
    transition: transform 0.1s ease-in-out;

    @media (prefers-reduced-motion) {
      transition: none;
    }

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
</style>
