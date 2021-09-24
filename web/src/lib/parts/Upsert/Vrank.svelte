<script context="module">
  const lbls = [
    ['Cao', 4],
    ['Bình', 3],
    ['Thấp', 2],
    ['Đáy', 1],
  ]

  const keys = { 1: 'b', 2: 'l', 3: 'm', 4: 'h' }
</script>

<script>
  export let rank = 3
  export let vhint
</script>

<div class="prio">
  <div class="lbl" title="Độ ưu tiên của cụm từ khi phân tách câu văn">
    Độ ưu tiên:
  </div>

  {#each lbls as [lbl, val], idx}
    <button
      class="btn"
      class:active={rank == val}
      data-kbd={keys[val]}
      on:click={() => (rank = val)}
      on:mouseenter|stopPropagation={() => (vhint = idx + 6)}>{lbl}</button>
  {/each}
</div>

<style lang="scss">
  .prio {
    flex: 1;
    @include flex($gap: 0.375rem, $center: both);
    margin-right: 0.375rem;
  }

  .lbl,
  .btn {
    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1.75rem;
  }

  .lbl {
    @include bps(display, none, $sm: inline-block);
  }

  .btn {
    padding: 0 0.75rem;
    font-weight: 500;

    @include bgcolor(tranparent);
    @include linesd(--bd-main);
    @include bdradi(0.5rem);

    &:hover,
    &.active {
      @include fgcolor(primary, 5);
    }

    &.active {
      @include linesd(primary, 4, $ndef: false);
    }
  }
</style>
