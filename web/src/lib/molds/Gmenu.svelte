<script>
  export let loc = 'bottom'
  export let dir = 'center'
</script>

<menu-wrap class={$$props.class || ''}>
  <slot name="trigger" />

  <menu-body class="{loc} {dir}">
    <div class="content">
      <slot name="content" />
    </div>
  </menu-body>
</menu-wrap>

<style lang="scss">
  menu-wrap {
    display: block;
    position: relative;
  }

  // prettier-ignore
  menu-body {
    display: none;
    position: absolute;
    z-index: 999;
    width: var(--menu-width, 11rem);

    &.top {
      bottom: 100%;
      .content { margin-bottom: 0.5rem; }
    }

    &.bottom {
      top: 100%;
      .content { margin-top: 0.5rem; }
    }

    &.left { left: 0; }
    &.right { right: 0; }
    &.center { left: 50%; transform: translateX(-50%);}

    // prettier-ignore
    menu-wrap:hover > &, menu-wrap.active > & { display: block; }
  }

  .content {
    padding: 0.5rem 0;
    @include shadow(2);
    @include bdradi();
    @include bgcolor(secd);
  }

  .content :global(.-item) {
    display: block;
    width: 100%;
    padding: 0.5rem;
    line-height: 1.25rem;
    // text-transform: uppercase;
    font-weight: 500;

    @include flex(0);

    @include border(--bd-main, $loc: top);
    &:last-child {
      @include border(--bd-main, $loc: bottom);
    }

    // @include ftsize(sm);

    @include fgcolor(tert);
    background: inherit;

    &:hover {
      @include fgcolor(primary, 5);
      @include bgcolor(tert);
    }
  }

  .content :global(svg) {
    margin: 0 0.5rem;
    width: 1.25rem;
    height: 1.25rem;
  }

  .content :global(.-right) {
    margin-left: auto;
  }
</style>
