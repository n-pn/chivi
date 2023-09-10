<script context="module" lang="ts">
  type Prio = [number, string, string, string]

  const options: Prio[] = [
    [3, 'Cao', 'a', 'Cụm từ được ưu tiên cao khi phân tách câu văn'],
    [2, 'Bình', 's', 'Cụm từ ưu tiên trung bình, giá trị mặc định'],
    [1, 'Thấp', 'd', 'Cụm từ không được ưu tiên khi phân tách câu văn'],
    [0, 'Ẩn', 'f', 'Cụm từ không được áp dụng trong khi dịch'],
  ]
</script>

<script lang="ts">
  import { type CvtermForm, hint } from './_shared'

  export let form: CvtermForm
</script>

<div class="prio">
  <span class="lbl" use:hint={'Độ ưu tiên của cụm từ khi phân tách câu văn'}
    >Độ ưu tiên:</span>

  {#each options as [val, lbl, kbd, tip]}
    <button
      class="btn"
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

    &:hover {
      @include bgcolor(tert);
    }

    &._base {
      font-style: italic;
      // @include fgcolor(green, 5);
    }

    &._curr {
      @include fgcolor(primary, 5);
      @include linesd(primary, 4, $ndef: false);
    }

    &:last-child {
      margin-left: 0.375rem;
    }
  }
</style>
