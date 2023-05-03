<script context="module" lang="ts">
  const split_modes = [
    [0, 'Phân thủ công bằng ///'],
    [1, 'Phân bởi dòng trắng giữa chương'],
    [2, 'Nội dung thụt vào so với tên chương'],
    [3, 'Theo định dạng tên chương'],
    [4, 'Theo regular expression tự nhập'],
  ]

  export class Opts {
    split_mode = 1
    // split mode 1
    min_blanks = 2
    trim_space = false
    // split mode 2
    need_blank = false
    // split mode 3
    chdiv_labels = '章节回幕折集卷季'
    //split mode 4
    custom_regex = `^第[\\d零〇一二两三四五六七八九十百千]+[章节回]`
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let opts: Opts = new Opts()
  export let _onload: boolean = false
</script>

<div>
  <div class="label">
    <span>Cách chia chương:</span>
    <a class="guide" href="/hd/chuong-tiet/them-loat-chuong" target="_blank">
      <span>Giải thích</span>
      <SIcon name="external-link" />
    </a>
  </div>

  <select
    name="split_mode"
    class="m-input _sm"
    disabled={_onload}
    bind:value={opts.split_mode}>
    {#each split_modes as [value, label]}
      <option {value}>{label}</option>
    {/each}
  </select>
</div>

<div class="options">
  {#if opts.split_mode == 1}
    <label
      >Số dòng trắng tối thiểu: <input
        class="m-input _xs"
        type="number"
        name="min_blanks"
        bind:value={opts.min_blanks}
        min={1}
        max={4} /></label>

    <label
      ><input
        class="m-input"
        type="checkbox"
        name="trim_space"
        bind:checked={opts.trim_space} /> Lọc bỏ dấu cách</label>
  {:else if opts.split_mode == 2}
    <label
      ><input
        class="m-input"
        type="checkbox"
        name="need_blank"
        bind:checked={opts.need_blank} /> Phía trước phải là dòng trắng</label>
  {:else if opts.split_mode == 3}
    <label
      >Đằng sau <code>第[số từ]+</code> là:
      <input
        class="m-input _xs"
        name="label"
        bind:value={opts.chdiv_labels} /></label>
  {:else if opts.split_mode == 4}
    <label
      >Regex:
      <input
        class="m-input _xs"
        name="regex"
        bind:value={opts.custom_regex} /></label>
  {/if}
</div>

<style lang="scss">
  select {
    padding: 0 0.25rem;
    width: 100%;
  }

  .options {
    display: flex;
    flex-wrap: wrap;
    // line-height: 2rem;
    margin-top: 0.25rem;
    align-items: center;
    justify-content: space-between;
    gap: 0.75rem;
  }

  label {
    @include fgcolor(secd);
    @include hover() {
      cursor: pointer;
    }
  }

  .label {
    line-height: 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;

    font-size: rem(15px);

    > span {
      @include fgcolor(tert);
      font-weight: 500;
    }
  }

  .options {
    // display: flex;
    // flex-wrap: wrap;
    // gap: 0.5rem;
    // align-items: center;
    padding: 0.25rem 0;
  }

  [name='min_blanks'] {
    width: 2rem;
    text-align: center;
  }

  [name='regex'] {
    width: 20rem;
  }

  .guide {
    display: inline-block;
    margin-left: 1rem;
    display: inline-block;
    @include fgcolor(warning, 5);
    &:hover {
      @include fgcolor(warning, 4);
    }
  }
</style>
