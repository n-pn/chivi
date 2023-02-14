<script context="module" lang="ts">
  type Prio = [number, string, string, string]

  const prios: Prio[] = [
    [3, 'd', 'Cao', 'Được ưu tiên cao khi phân tách câu văn'],
    [2, 's', 'Bình', 'Độ ưu tiên trung bình, giá trị mặc định'],
    [1, 'a', 'Thấp', 'Không được ưu tiên khi phân tách câu văn'],
    [0, 'f', 'Ẩn', 'Không dùng cụm từ khi phân tách câu văn'],
  ]
</script>

<script lang="ts">
  import { hint, VpForm } from './_shared'

  export let form: VpForm
</script>

<div class="prio">
  <div class="lbl" title="Độ ưu tiên của cụm từ khi phân tách câu văn">
    Độ ưu tiên:
  </div>

  {#each prios as [val, kbd, lbl, tip], idx}
    <button
      class="btn"
      class:_del={idx == 3}
      class:_base={form.init.prio == val}
      class:_curr={form.prio == val}
      data-kbd={kbd}
      on:click={() => (form.prio = val)}
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
