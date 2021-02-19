<script>
  export let dname
  export let active
  export let exists
  export let idx
  $: kbd = idx == 0 ? 'x' : idx == 1 ? 'c' : 'v'
</script>

<span class="tab" class:active class:exists data-kbd={kbd} on:click>
  {dname}
</span>

<style lang="scss">
  $height: 2.25rem;

  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;

    height: $height;
    line-height: $height;

    flex-shrink: 0;

    @include truncate(null);
    @include font-size(2);
    @include fgcolor(neutral, 5);

    @include radius($sides: top);
    @include border($color: neutral, $sides: top-left-right);

    &:first-child {
      max-width: 36%;
      flex-shrink: 1;
    }

    &.exists {
      @include fgcolor(neutral, 7);
    }

    &.active {
      @include bgcolor(#fff);
      @include fgcolor(primary, 6);
      @include bdcolor($color: primary, $shade: 4);
    }
  }
</style>
