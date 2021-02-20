<script context="module">
  const types = [
    ['N', 'Danh', 'D..'],
    ['V', 'Động', 'Đ..'],
    ['A', 'Tính', 'T..'],
  ]
</script>

<script>
  export let attr = 0
</script>

<div class="attr">
  {#each types as [val, lbl_full, lbl_trim], idx}
    <button
      class="-val"
      data-kbd={val}
      class:active={attr & (1 << idx)}
      on:click={() => (attr = attr ^ (1 << idx))}>
      <span class="-full">{lbl_full}</span>
      <span class="-trim">{lbl_trim}</span>
    </button>
  {/each}
</div>

<style lang="scss">
  .attr {
    display: flex;
    position: absolute;
    right: 0.5rem;
    top: 2.75rem;
    line-height: 1.5rem;
  }

  .-val {
    padding: 0 0.375rem;
    text-transform: uppercase;
    font-weight: 500;

    background: transparent;
    opacity: 0.9;

    @include fgcolor(neutral, 5);

    @include border();
    @include radius(0.5rem);

    @include props(font-size, rem(14px), $md: rem(12px));

    &:hover,
    &.active {
      @include fgcolor(primary, 5);
    }

    &.active {
      @include bdcolor(primary, 4);
    }

    // prettier-ignore
    & + & { margin-left: 0.375rem; }
  }

  .-full {
    @include props(display, none, $md: inline-block);
  }

  .-trim {
    @include props(display, inline-block, $md: none);
  }
</style>
