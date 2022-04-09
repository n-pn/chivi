<script lang="ts">
  export let loc = 'bottom'
  export let dir = 'center'

  export let lbl = ''
</script>

<menu-wrap class={$$props.class || ''}>
  <slot name="trigger" />

  <menu-body class="{loc} {dir}">
    <div class="content">
      {#if lbl}<header class="header">{lbl}</header>{/if}

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
    menu-wrap:hover > &, menu-wrap._active > & { display: block; }
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
</style>
