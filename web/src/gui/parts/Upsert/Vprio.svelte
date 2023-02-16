<script context="module" lang="ts">
  type Prio = [number, string]

  const prios: Prio[] = [
    [3, 'Cao'],
    [2, 'Bình'],
    [1, 'Thấp'],
    [0, 'Ẩn'],
  ]

  const prio_tips = {
    3: 'Được ưu tiên cao khi phân tách câu văn',
    2: 'Độ ưu tiên trung bình, giá trị mặc định',
    1: 'Không được ưu tiên khi phân tách câu văn',
    0: 'Không dùng cụm từ khi phân tách câu văn',
  }

  // const prio_kbds = [
  //   [3, 'd'],
  //   [2, 's'],
  //   [1, 'a'],
  //   [0, 'f'],
  // ]
</script>

<script lang="ts">
  import type { VpForm } from './_shared'

  export let form: VpForm
  export let udict: CV.VpDict

  let dicts = {
    [udict.vd_id]: {
      lbl: 'Bộ truyện hiện tại',
      tip: `Áp dụng nghĩa của từ cho bộ truyện ${udict.label}`,
    },
    [-2]: {
      lbl: 'Tất cả các truyện',
      tip: `Áp dụng nghĩa của từ cho tất cả các bộ truyện`,
    },
    0: {
      lbl: 'Tự động lựa chọn',
      tip: 'Hệ thống sẽ tự động chọn phạm vi ứng dụng hợp lý nhất',
    },
  }

  $: dict_tip = dicts[form.dic]?.tip
</script>

<div class="prio">
  <label data-tip={dict_tip} data-tip-pos="left">
    <span class="lbl">Áp dụng:</span>
    <select name="dic" class="m-input _dic" bind:value={form.dic}>
      {#each Object.entries(dicts) as [val, { lbl }]}
        <option value={+val}>{lbl} </option>
      {/each}
    </select>
  </label>

  <label data-tip={prio_tips[form.prio]}>
    <span class="lbl">Ưu tiên:</span>
    <select name="prio" class="m-input _prio" bind:value={form.prio}>
      {#each prios as [val, lbl]}
        <option value={val}>{lbl}</option>
      {/each}
    </select>
  </label>
</div>

<style lang="scss">
  .prio {
    flex: 1;
    @include flex($gap: 0.375rem, $center: both);
    margin-right: 0.375rem;
  }

  .lbl {
    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1.75rem;
    @include bps(display, none, $pl: inline-block);
  }

  select {
    font-size: rem(14px);
  }

  select._dic {
    width: 9rem;
  }

  select._prio {
    width: 4rem;
  }

  option {
    font-size: rem(16px);
  }
  // .btn {
  //   padding: 0 0.75rem;
  //   font-weight: 500;

  //   @include bgcolor(tranparent);
  //   @include linesd(--bd-main);
  //   @include bdradi(0.5rem);

  //   &._base {
  //     font-style: italic;
  //     // @include fgcolor(green, 5);
  //   }

  //   &._curr {
  //     @include fgcolor(primary, 5);
  //     @include linesd(primary, 4, $ndef: false);
  //   }

  //   &:hover {
  //     @include bgcolor(tert);
  //   }
  // }
</style>
