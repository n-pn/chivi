<script lang="ts">
  export let loc = 'bottom'
  export let dir = 'center'
  export let lbl = ''

  export let active = false

  const trigger = (_: any) => (active = !active)
  const deactive = () => (active = false)
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<div
  class="gmenu {$$props.class || ''}"
  class:_active={active}
  on:blur={deactive}
  on:mouseleave={deactive}>
  <div class="trigger"><slot name="trigger" {trigger} /></div>

  <div class="gmenu-body {loc} {dir}">
    <div class="content">
      {#if lbl}<header class="header">{lbl}</header>{/if}
      <slot name="content" />
    </div>
  </div>
</div>

<style lang="scss">
  .gmenu {
    display: block;
    position: relative;
  }

  .gmenu-body {
    display: none;
    position: absolute;
    z-index: 99999;
    width: var(--menu-width, 11rem);

    &.top {
      bottom: 100%;
      // prettier-ignore
      .content { margin-bottom: 0.5rem; }
    }

    &.bottom {
      top: 100%;
      // prettier-ignore
      .content { margin-top: 0.5rem; }
    }

    // prettier-ignore
    &.left { left: 0; }
    // prettier-ignore
    &.right { right: 0; }
    // prettier-ignore
    &.center { left: 50%; transform: translateX(-50%);}

    .gmenu:hover > &,
    .gmenu._active > & {
      display: block;
    }
  }

  .content {
    padding: 0.5rem 0;
    @include shadow(2);
    @include bdradi();
    @include bgcolor(secd);
  }

  .header {
    padding: 0 1rem 0.25rem;
    line-height: 1.25rem;

    font-weight: 500;
    font-size: rem(13px);

    @include border(--bd-soft, $loc: bottom);
    @include fgcolor(tert);
  }

  :global(.gmenu-item) {
    @include flex();
    width: 100%;

    padding: 0.5rem 1rem;
    line-height: 1.25rem;

    font-weight: 500;
    font-size: rem(15px);

    background: inherit;
    @include fgcolor(secd);

    &:hover {
      @include fgcolor(primary, 5);
      @include bgcolor(tert);
    }

    > :global(* + *) {
      margin-left: 0.5rem;
    }

    :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
    }

    > :global(.-right) {
      margin-left: auto;
    }
  }

  .trigger {
    display: contents;
  }
</style>
