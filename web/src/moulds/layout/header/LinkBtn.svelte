<script>
  export let href = '/'
</script>

<style lang="scss">
  $header: 3rem;
  $height: 2.25rem;
  $gutter: ($header - $height) / 2;

  a {
    display: inline-flex;
    // max-width: 10rem;
    cursor: pointer;

    text-decoration: none;
    padding: 0 0.5rem;
    height: $height;

    text-transform: uppercase;
    font-weight: 500;

    @include color(neutral, 2);

    @include radius(3);
    @include font-size(2);
    @include bgcolor(primary, 5);

    @include hover() {
      @include bgcolor(primary, 4);
    }

    & + & {
      margin-left: $gutter;
    }

    :global(&.active) {
      @include bgcolor(primary, 4);
    }

    :global(img),
    :global(svg) {
      display: inline-block;
      margin: 0.5rem 0;
      // margin-top: -0.125rem;
      width: 1.25rem;
      height: 1.25rem;
    }

    :global(&.logo) {
      letter-spacing: 0.1em;
      @include font-size(3);

      // > :global(img) {
      //   display: inline-block;
      //   margin: 0.25rem 0;
      //   // margin-top: -0.25rem;
      //   width: 1.75rem;
      //   height: 1.75rem;
      // }

      > :global(span) {
        padding: 0;
        margin-left: 0.25rem;
        margin-right: 0;
      }
    }
  }
</style>

<a {href} class={$$props.class}>
  <slot />
</a>
