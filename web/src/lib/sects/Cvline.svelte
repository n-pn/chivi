<script>
  export let input
  export let focus = false
</script>

<cv-line>{@html focus ? input.html : input.text}</cv-line>

<style lang="scss" global>
  @mixin cv-node($color: blue) {
    cursor: pointer;
    // position: relative;

    @include tm-light {
      --active: #{color($color, 6)};
      --border: #{color($color, 4)};
    }

    @include tm-dark {
      --active: #{color($color, 4)};
      --border: #{color($color, 6)};
    }
  }

  v-n {
    background-position: bottom bottom;

    cv-data:hover &,
    cv-data.focus &,
    cv-data.debug &,
    &:hover {
      // border-bottom: 1.5px ridge var(--border);
      background: linear-gradient(to top, var(--border) 0.75px, transparent 0);
    }

    // essence + fixture
    &[data-d='1'] {
      @include cv-node(gray);
      background: none !important;
    }

    // regular + public
    &[data-d='2'] {
      @include cv-node(blue);
    }

    // unique + public
    &[data-d='3'] {
      @include cv-node(orange);
    }

    // regular + private
    &[data-d='4'] {
      @include cv-node(teal);
    }

    // unique + private
    &[data-d='5'] {
      @include cv-node(red);
    }

    &:hover,
    &.hover {
      color: var(--active);
    }

    // prettier-ignore
    &.focus {
      @include fgcolor(secd);
      background: color(success, 5, 2);
      @include tm-dark { background: color(purple, 4, 2); }
    }

    c-g & {
      cursor: pointer;
      // prettier-ignore
      &:hover, &.hover, &.focus { color: var(--active); }
    }
  }

  // prettier-ignore
  @mixin vg-wrap($left: '{', $right: '}') {
    &:before, &:after { font-style: normal; }
    &:before { content: $left; }
    &:after { content: $right; }
  }

  v-g {
    --vgcolor: var(--fgmain);

    cv-data.debug & {
      background: none !important;

      // prettier-ignore
      &:before, &:after { color: var(--vgcolor); }
      @include vg-wrap('[', ']');

      v-n {
        color: var(--vgcolor);
        // prettier-ignore
        &:hover { color: var(--active); }
      }
    }

    &[data-d='0'],
    &[data-d='1'] {
      @include vg-wrap('', '');
    }

    $colors: (gray, green, blue, teal, orange, fuchsia, purple, pink, red);

    @for $i from 1 through 9 {
      &[data-d='#{$i}'] {
        $color: list.nth($colors, $i);
        --vgcolor: #{color($color, 5)};
      }
    }
  }
</style>
