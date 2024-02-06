<script context="module" lang="ts">
  const split_modes = [
    [0, 'Tự động nhận dạng cách chia'],
    [1, 'Phân thủ công bằng ///'],
    [2, 'Phân bởi dòng trắng giữa chương'],
    [3, 'Nội dung thụt vào so với tên chương'],
    [4, 'Theo định dạng tên chương'],
    [5, 'Theo regular expression tự nhập'],
    [6, 'Chia văn bản theo số chữ mỗi phần'],
  ]
</script>

<script lang="ts">
  import { Cztext, type Czdata } from './czdata'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Czcard from './Czcard.svelte'
  import Czlist from './Czlist.svelte'

  export let ztext: string = ''

  export let ch_no: number = 1
  export let state: number = 0

  export let chaps: Czdata[] = []
  export let show_preview = false

  let error = ''

  let xopts = {
    split_mode: 0,
    // mode 1
    div_marker: '///',
    // mode 2
    min_blanks: 2,
    // mode 3
    need_blank: false,
    // mode 4
    chdiv_labels: '章节回幕折集卷季',
    // mode 5
    custom_regex: `^第[\\d零〇一二两三四五六七八九十百千]+[章节回]`,
    // mode 6
    chunk_length: 10000,
  }

  $: zdata = new Cztext(ztext, ch_no)
  $: if (xopts) {
    error = ''
    state = 1
    chaps = zdata.split_text(xopts)
    state = 0
    error = zdata.error
  }
</script>

<div class="d-label">
  <label for="split_mode" data-tip="Số thứ tự khi chèn chương">Vị trí chương bắt đầu:</label>
  <input class="m-input _sm _fix u-right" type="number" name="ch_no" min={1} bind:value={ch_no} />
</div>

<label class="d-label" for="split_mode">
  <span>Chọn cách chia chương:</span>
  <a class="guide u-right" href="/hd/chuong-tiet/them-loat-chuong" target="_blank">
    <span>Giải thích cách chia</span>
  </a>
</label>

<div class="field">
  <select name="split_mode" class="m-input" disabled={state > 0} bind:value={xopts.split_mode}>
    {#each split_modes as [value, label]}
      <option {value}>{label}</option>
    {/each}
  </select>
</div>

<div class="d-label" hidden={xopts.split_mode != 0}>
  <p>Chương trình sẽ tự động thử các cách chia để tìm phương án hợp lý nhất</p>
</div>

<label class="d-label" hidden={xopts.split_mode != 1}>
  <span>Đoạn ký tự phân tách:</span>
  <input class="m-input _sm _fix u-right" name="div_marker" bind:value={xopts.div_marker} />
</label>

<label class="d-label" hidden={xopts.split_mode != 2}>
  <span>Số dòng trắng tối thiểu: </span>
  <input
    class="m-input _sm _fix u-right"
    type="number"
    name="min_blanks"
    bind:value={xopts.min_blanks}
    min={1} />
</label>

<label class="d-label" hidden={xopts.split_mode != 3}>
  <input type="checkbox" name="need_blank" bind:checked={xopts.need_blank} />
  <span>Phía trên tên chương phải là dòng trắng</span>
</label>

<label class="d-label" hidden={xopts.split_mode != 4}>
  <span>Đằng sau <code>第[số]+</code> là:</span>
  <input class="m-input _sm" name="label" bind:value={xopts.chdiv_labels} />
</label>

<label class="d-label" hidden={xopts.split_mode != 5}>
  <span>Regex:</span>
  <input class="m-input _sm _full u-right" name="regex" bind:value={xopts.custom_regex} />
</label>

<label class="d-label" hidden={xopts.split_mode != 6}>
  <span>Tổng số ký tự mỗi phần:</span>
  <input
    class="m-input _sm _fix u-right"
    type="number"
    name="chunk_length"
    min={500}
    max={3000}
    bind:value={xopts.chunk_length} />
</label>

{#if error}
  <div class="form-msg _err">{error}</div>
{/if}

<hr class="m-ruler" />

<h4 class="x-field">
  <span>Số chương kết quả:</span>
  <strong class="x-value">{chaps.length}</strong>
  <button
    class="m-btn _sm _success u-right"
    disabled={!chaps.length}
    on:click={() => (show_preview = !show_preview)}>
    <SIcon name="eye" />
    <span>Xem trước</span>
  </button>
</h4>

{#if chaps.length == 0}
  <div class="d-empty=sm">
    <em>Chưa có nội dung chương. Hãy nhập dữ liệu bên tay trái!</em>
  </div>
{:else if chaps.length == 1}
  <h4 class="h4">Thông tin tổng quát chương</h4>

  <div class="x-field">
    <span class="v-label">Tên chương tiết: </span>
    <span class="u-right u-fg-main">{chaps[0].title}</span>
  </div>

  <div class="x-field">
    <span class="v-label">Tên tập truyện: </span>
    <span class="u-right u-fg-main">{chaps[0].chdiv || 'N/A'}</span>
  </div>

  <div class="x-field">
    <span class="v-label">Số ký tự: </span>
    <span class="u-right u-fg-main">{chaps[0].size}</span>
    <SIcon name={chaps[0].size > 100000 ? 'x' : 'check'} />
  </div>

  <div class="x-field">
    <span class="v-label">Số phần: </span>
    <span class="u-right u-fg-main">{chaps[0].parts.length}</span>
    <SIcon name={chaps[0].parts.length > 30 ? 'x' : 'check'} />
  </div>
{:else}
  <div class="d-label">Các chương đầu</div>
  {#each chaps.slice(0, 3) as zdata, index}
    <Czcard {zdata} index={index + 1} />
  {/each}

  {#if chaps.length > 4}
    <div class="d-label">Các chương cuối</div>
    {#each chaps.slice(chaps.length - 3) as zdata, index}
      <Czcard {zdata} index={index + chaps.length - 2} />
    {/each}
  {/if}
{/if}

{#if chaps.length && show_preview}
  <Czlist {chaps} bind:actived={show_preview} />
{/if}

<style lang="scss">
  .guide {
    font-style: italic;
    @include fgcolor(warning, 5);
    &:hover {
      @include fgcolor(warning, 4);
    }
  }

  label {
    @include flex-ca($gap: 0.5rem);
  }

  select {
    width: 100%;
    max-width: 25rem;
  }

  .field {
    @include flex-cy($gap: 0.5rem);
    margin-bottom: 0.75rem;
  }

  .x-field {
    @include flex-cy($gap: 0.5rem);
  }

  .m-input.m-input {
    padding-left: 0.5rem;
    padding-right: 0.5rem;
  }

  ._full {
    flex: 1;
  }

  ._fix {
    text-align: center;
    width: 4rem;
  }

  .h4 {
    @include border($loc: top);
    margin-top: 0.75rem;
    padding-top: 0.5rem;
  }
</style>
