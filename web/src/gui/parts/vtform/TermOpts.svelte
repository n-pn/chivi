<script context="module" lang="ts">
  type SaveTab = [number, string, string]

  const save_tabs: SaveTab[] = [
    [1, 'Chung', 'Nghĩa của từ sẽ được áp dụng tất cả mọi người'],
    [2, 'Riêng', 'Nghĩa của từ chỉ áp dụng cho riêng cá nhân bạn'],
  ]
</script>

<script lang="ts">
  import { type CvtermForm, hint, req_privi } from './_shared'

  export let tform: CvtermForm
  export let privi: number
  export let vdict: CV.Cvdict
</script>

<section class="opts">
  <span class="choices">
    <span class="label _hide">Phạm vi:</span>
    <label class="label" use:hint={'Áp dụng nghĩa từ cho bộ truyện hiện tại'}>
      <input
        type="radio"
        name="term-dic"
        bind:group={form.dic}
        disabled={privi < req_privi(0, form.tab)}
        value={vdict.vd_id} />
      <span>Bộ này</span>
    </label>

    <label class="label" use:hint={'Áp dụng nghĩa từ cho tất cả các bộ truyện'}>
      <input
        type="radio"
        name="dic"
        bind:group={form.dic}
        disabled={privi < req_privi(-1, form.tab)}
        value={-1} />
      <span>Tất cả</span>
    </label>
  </span>
  <span class="choices _right">
    <span class="label _hide">Cách lưu:</span>

    {#each save_tabs as [value, label, brief]}
      <label class="label" class:_active={form.tab == value} use:hint={brief}>
        <input
          type="radio"
          name="term-tab"
          bind:group={form.tab}
          disabled={privi < req_privi(form.dic, value)}
          {value} />
        <span class="-text">{label}</span>
      </label>
    {/each}
  </span>
</section>

<style lang="scss">
  .opts {
    display: flex;
    margin-top: 0.5rem;
    margin-bottom: -0.25rem;
  }

  .label {
    cursor: pointer;
    line-height: 1.25rem;
    // font-weight: 500;

    @include bps(font-size, rem(12px), $pm: rem(13px), $pl: rem(14px));

    @include fgcolor(tert);

    &._active {
      @include fgcolor(secd);
    }
  }

  .choices {
    display: flex;
    gap: 0.5rem;
  }

  ._hide {
    @include bps(display, none, $pl: initial);
  }

  ._right {
    margin-left: auto;
  }
</style>
