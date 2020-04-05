<style lang="scss">
  $header: 3rem;
  $height: 2.25rem;
  $gutter: ($header - $height) / 2;

  a {
    display: inline-flex;
    cursor: pointer;

    text-decoration: none;
    padding: 0 0.5rem;
    height: $height;

    text-transform: uppercase;
    font-weight: 500;

    @include color(neutral, 2);

    @include radius(3);
    @include font-size(2);
    @include bgcolor(primary, 6);

    @include hover() {
      @include bgcolor(primary, 5);
    }

    & + & {
      margin-left: $gutter;
    }

    :global(&.active) {
      @include bgcolor(primary, 5);
    }

    :global(img),
    :global(svg) {
      display: inline-block;
      margin: 0.5rem 0;
      width: 1.25rem;
      height: 1.25rem;
    }

    :global(&.logo) {
      letter-spacing: 0.1em;
      @include font-size(3);

      > :global(span) {
        margin-left: 0.25rem;
      }
    }
  }
</style>

<a href={$$props.href} class={$$props.class}>
  <slot />
</a>
