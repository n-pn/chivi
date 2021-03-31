<script context="module">
  const priorities = { L: 'Thấp', M: 'Bình', H: 'Cao' }
</script>

<script>
  export let prio = 1
</script>

<div class="prio">
  <span class="-txt">Ưu tiên:</span>
  {#each Object.entries(priorities) as [val, lbl], idx}
    <button
      class="-btn"
      class:active={prio == idx}
      data-kbd={val}
      on:click={() => (prio = idx)}>{lbl}</button>
  {/each}
</div>

<style lang="scss">
  $outer-height: 2.5rem;
  $inner-height: 1.75rem;

  .prio {
    display: flex;
    flex: 1;
    justify-content: center;
    margin: ($outer-height - $inner-height) / 2 0;
    padding-top: 1px;
    // padding-top: 0.25rem;
    @include props(font-size, rem(11px), rem(12px), rem(13px));
  }

  .-txt,
  .-btn {
    // height: $inner-height;
    line-height: $inner-height;
    text-transform: uppercase;
    font-weight: 500;
    @include fgcolor(neutral, 4);
  }

  .-txt {
    margin-top: 1px;
    margin-right: 0.375rem;
    @include props(display, none, $md: inline-block);
  }

  .-btn {
    padding: 0 0.5rem;
    // margin: 0;

    background-color: #fff;

    @include fgcolor(neutral, 5);
    @include border();
    @include radius(0.5rem);

    &:hover,
    &.active {
      @include fgcolor(primary, 5);
    }

    &.active {
      @include bdcolor(primary, 4);
    }

    & + & {
      margin-left: 0.375rem;
    }
  }
</style>
