<script context="module" lang="ts">
  const prios = [
    ['^', 'd', 'Cao', 'Được ưu tiên cao khi phân tách câu văn'],
    ['', 's', 'Bình', 'Độ ưu tiên trung bình, giá trị mặc định'],
    ['v', 'a', 'Thấp', 'Không được ưu tiên khi phân tách câu văn'],
    ['x', 'f', 'Ẩn', 'Không dùng cụm từ khi phân tách câu văn'],
  ]
</script>

<script lang="ts">
  import type { VpTerm } from '$lib/vp_term'

  import { hint } from './_shared'

  export let vpterm: VpTerm
  export let prio = ''
</script>

<div class="prio">
  <div class="lbl" title="Độ ưu tiên của cụm từ khi phân tách câu văn">
    Độ ưu tiên:
  </div>

  {#each prios as [val, kbd, lbl, tip], idx}
    <button
      class="btn"
      class:_del={idx == 3}
      class:_base={vpterm.init.b_prio == val}
      class:_priv={vpterm.init.b_prio == val}
      class:_curr={prio == val}
      data-kbd={kbd}
      on:click={() => (prio = val)}
      use:hint={tip}>{lbl}</button>
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
