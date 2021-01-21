<script>
  export let d_name
  export let active
  export let exists
  export let idx
  $: kbd = idx == 0 ? 'x' : idx == 1 ? 'c' : 'v'
</script>

<span class="tab" class:active class:exists data-kbd={kbd} on:click>
  {d_name}
</span>

<style lang="scss">
  .tab {
    cursor: pointer;
    text-transform: uppercase;
    font-weight: 500;
    padding: 0 0.75rem;

    height: 2.25rem;
    line-height: 2.25rem;
    // margin-top: 0.25px;

    flex-shrink: 0;

    @include truncate(null);
    @include font-size(2);
    @include fgcolor(neutral, 5);

    @include radius($sides: top);
    @include border($color: neutral, $sides: top-left-right);

    &:first-child {
      max-width: 35%;
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
