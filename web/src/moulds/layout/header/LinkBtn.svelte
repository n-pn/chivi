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
    text-decoration: none;

    padding: 0 0.5rem;
    height: $height;

    // font-variant: small-caps;
    font-weight: 500;

    @include color(neutral, 2);

    @include radius(3);
    @include font-size(2);
    // @include bgcolor(primary, 5);

    @include hover() {
      @include bgcolor(primary, 4);
      color: #fff;
    }

    :global(&.logo) {
      text-transform: uppercase;
      letter-spacing: 0.1em;

      > :global(img) {
        display: inline-block;
        margin: 0.25rem 0;
        // margin-top: -0.125rem;
        width: 1.75rem;
        height: 1.75rem;
      }

      > :global(span) {
        margin-left: 0.25rem;
      }
    }

    :global(&.active) {
      @include bgcolor(primary, 5);
    }

    & + & {
      margin-left: $gutter;
    }

    :global(span) {
      @include truncate(100%);
      max-width: 30vw;
    }

    :global(img),
    :global(svg) {
      display: inline-block;
      margin: 0.5rem 0;
      // margin-top: -0.125rem;
      width: 1.25rem;
      height: 1.25rem;
    }
  }
</style>

<a {href} class={$$props.class}>
  <slot />
</a>
