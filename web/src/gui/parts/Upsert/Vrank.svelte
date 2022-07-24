<script context="module" lang="ts">
  const keys = ['a', 's', 'd', 'f']
  const lbls = ['Cao', 'Bình', 'Thấp']
  const labels = ['Hơi cao', 'Trung bình', ' Hơi thấp']
</script>

<script lang="ts">
  import type { VpTerm } from '$lib/vp_term'

  import { hint } from './_shared'

  export let vpterm: VpTerm
  export let rank = 2
</script>

<div class="prio">
  <div class="lbl" title="Độ ưu tiên của cụm từ khi phân tách câu văn">
    Độ ưu tiên:
  </div>

  {#each lbls as lbl, idx}
    <button
      class="btn"
      class:_base={vpterm.init.b_rank == 3 - idx}
      class:_priv={vpterm.init.b_rank == 3 - idx}
      class:_curr={rank == 3 - idx}
      data-kbd={keys[idx]}
      on:click={() => (rank = 3 - idx)}
      use:hint={'Mức độ ưu tiên: ' + labels[idx]}>{lbl}</button>
  {/each}

  <button
    class="btn _del"
    class:_base={vpterm.init.b_rank == 0}
    class:_priv={vpterm.init.b_rank == 0}
    class:_curr={rank == 0}
    data-kbd={keys[4]}
    on:click={() => (rank = 0)}
    use:hint={'Đảm bảo cụm từ không được áp dụng khi dịch'}>Xoá</button>
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
    @include bps(display, none, $pl: inline-block);
  }

  .btn {
    padding: 0 0.75rem;
    font-weight: 500;

    @include bgcolor(tranparent);
    @include linesd(--bd-main);
    @include bdradi(0.5rem);

    &._base {
      font-style: italic;
      // @include fgcolor(green, 5);
    }

    &._priv {
      @include fgcolor(secd);
    }

    &._curr {
      @include fgcolor(primary, 5);
      @include linesd(primary, 4, $ndef: false);
    }

    &:hover {
      @include bgcolor(tert);
    }
  }

  ._del {
    margin-left: 0.375rem;
  }
</style>
