<script context="module" lang="ts">
  export function show_txt(
    mode: number,
    lmax: number,
    l_index: number,
    l_hover: number,
    l_focus: number
  ) {
    if (mode == 1) return true
    if (l_index == l_hover) return false

    if (l_index > l_focus - 3 && l_index < l_focus + 3) return false
    if (l_focus == 0) return l_index != lmax

    return l_index != 0 || l_focus != lmax
  }
</script>

<script lang="ts">
  import MtData from '$lib/mt_data'

  export let input: MtData = new MtData('')
  export let plain = false
</script>

<cv-line>{@html plain ? input.text : input.html}</cv-line>

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

    .cdata:hover &,
    .cdata.focus &,
    .cdata.debug &,
    &:hover {
      // border-bottom: 1.5px ridge var(--border);
      background: linear-gradient(to top, var(--border) 0.75px, transparent 0);
    }

    // essence + fixture
    &[data-d='1'] {
      @include cv-node(gray);
      background: none !important;
    }

    // regular + main
    &[data-d='2'] {
      @include cv-node(primary);
    }

    // regular + temp
    &[data-d='3'] {
      @include cv-node(harmful);
    }

    // regular + user
    &[data-d='4'] {
      @include cv-node(purple);
    }

    // regular + init
    &[data-d='5'] {
      @include cv-node(success);
      font-weight: bold;
    }

    // unique + main
    &[data-d='6'] {
      @include cv-node(teal);
    }

    // unique + temp
    &[data-d='7'] {
      @include cv-node(warning);
    }

    // unique + user
    &[data-d='8'] {
      @include cv-node(pink);
    }

    &:hover,
    &.hover {
      color: var(--active);
    }

    // prettier-ignore
    &.focus {
      @include fgcolor(secd);
      background: color(success, 5, 2) !important;
      .tm-dark & { background: color(purple, 4, 3) !important; }
      .tm-oled & { background: color(purple, 4, 4) !important; }
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

    .cdata.debug & {
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
