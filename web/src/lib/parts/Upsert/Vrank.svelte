<script context="module">
  const keys = ['a', 's', 'd', 'f']
  const lbls = ['Cao', 'Bình', 'Thấp', 'Đáy']
  const labels = ['Hơi cao', 'Trung bình', ' Hơi thấp', 'Rất thấp']
</script>

<script>
  import { hint } from './_shared'

  export let rank = 3
</script>

<div class="prio">
  <div class="lbl" title="Độ ưu tiên của cụm từ khi phân tách câu văn">
    Độ ưu tiên:
  </div>

  {#each lbls as lbl, idx}
    <button
      class="btn"
      class:active={rank == 4 - idx}
      data-kbd={keys[idx]}
      on:click={() => (rank = 4 - idx)}
      use:hint={'Độ ưu tiên của từ trong câu văn: ' + labels[idx]}
      >{lbl}</button>
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
