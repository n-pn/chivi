<script context="module">
  const lbls = { 2: 'Thấp', 3: 'Bình', 4: 'Cao' }
  const keys = { 2: 'l', 3: 'm', 4: 'h' }
</script>

<script>
  export let rank = 3
</script>

<div class="prio">
  <span class="-txt">Ưu tiên:</span>
  {#each Object.entries(lbls) as [val, lbl]}
    <button
      class="-btn"
      class:active={rank == val}
      data-kbd={keys[val]}
      on:click={() => (rank = val)}>{lbl}</button>
  {/each}
</div>

<style lang="scss">
  $outer-height: 2.5rem;
  $inner-height: 1.75rem;

  .prio {
    display: flex;
    flex: 1;
    justify-content: center;
    margin: math.div($outer-height - $inner-height, 2) 0;
    padding-top: 1px;
    // padding-top: 0.25rem;
    @include fluid(font-size, rem(11px), rem(12px), rem(13px));
  }

  .-txt,
  .-btn {
    // height: $inner-height;
    line-height: $inner-height;
    text-transform: uppercase;
    font-weight: 500;
  }

  .-txt {
    margin-top: 1px;
    margin-right: 0.375rem;
    @include fgcolor(mute);
    @include fluid(display, none, $md: inline-block);
  }

  .-btn {
    padding: 0 0.5rem;
    // margin: 0;

    @include bgcolor(tranparent);
    @include fgcolor(secd);

    @include linesd(--bd-main);
    @include bdradi(0.5rem);

    &:hover,
    &.active {
      @include fgcolor(primary, 5);
    }

    &.active {
      @include linesd(primary, 4, $ndef: false);
    }

    & + & {
      margin-left: 0.375rem;
    }
  }
</style>
