<script>
  export let loc = 'bottom'
  export let dir = 'center'
</script>

<div class="menu {$$props.class || ''}">
  <slot name="trigger" />

  <div class="popup _{loc} _{dir}">
    <div class="content">
      <slot name="content" />
    </div>
  </div>
</div>

<style lang="scss">
  .menu {
    position: relative;
  }

  // prettier-ignore
  .popup {
    display: none;
    position: absolute;
    z-index: 999;
    width: var(--menu-width, 11rem);

    &._top {
      bottom: 100%;
      .content { margin-bottom: 0.5rem; }
    }

    &._bottom {
      top: 100%;
      .content { margin-top: 0.5rem; }
    }

    &._left { left: 0; }
    &._right { right: 0; }
    &._center { left: 50%; transform: translateX(-50%);}

    // prettier-ignore
    .menu:hover > &, .menu._active > & { display: block; }
  }

  .content {
    padding: 0.5rem 0;
    @include shadow(2);
    @include bdradi();
    @include bgcolor(secd);
  }

  .content > :global(.-item) {
    display: block;
    width: 100%;
    padding: 0 0.5rem;
    line-height: 2.25rem;
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

    :global(svg) {
      margin: 0.5rem;
      width: 1.25rem;
      height: 1.25rem;
    }
  }
</style>
