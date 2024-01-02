<script lang="ts">
  import type { Czdata } from './czdata'

  export let zdata: Czdata
  export let index = 1
</script>

<div class="zdata">
  <div class="zmain">
    <span class="index">{index}.</span>
    <span class="title">{zdata.title}</span>
    <em class="u-right"
      ><span class="u-fg-tert">Vị trí chương:</span>
      <strong class="u-warn">{zdata.ch_no}.</strong></em>
  </div>

  <div class="zsecd">
    <span class="chdiv">Tên tập: <strong>{zdata.chdiv || '--'}</strong></span>

    <span class="c_len u-right">
      Số chữ: <strong class="u-warn">{zdata.size}</strong>
    </span>

    <span class="c_len">
      Chia phần: <strong class="u-warn">{zdata.parts.length}</strong>
    </span>
  </div>
</div>

<style lang="scss">
  .zdata {
    padding-top: 0.125rem;
    @include border(--bd-soft, $loc: top);

    &:last-child {
      @include border(--bd-soft, $loc: bottom);
    }
  }

  .zmain {
    display: flex;
    gap: 0.25rem;
    line-height: 1.25rem;
    font-size: smaller;
  }

  .zsecd {
    @include flex-cy($gap: 0.25rem);
    line-height: 1.25rem;
    font-style: italic;
    @include ftsize(xs);
  }

  .index {
    font-weight: 500;
    font-size: rem(12px);
    @include fgcolor(warning, 5);
  }

  .title {
    @include clamp;
    flex-shrink: 1;
    max-width: 30ch;
    @include fgcolor(secd);
  }

  .chdiv {
    @include clamp;
    flex-shrink: 1;
    max-width: 20ch;
  }

  .chdiv,
  .c_len,
  .ch_no {
    @include fgcolor(tert);
  }

  .ch_no {
    @include ftsize(sm);
  }
</style>
