<script lang="ts">
  // import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import { api_call } from '$lib/api_call'
  import { seed_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let book_info: CV.Wninfo
  export let curr_seed: CV.Chroot

  export let can_edit = false
  export let edit_url: string

  let cut_from = 1
  let cut_upto = curr_seed.chmax

  async function cut_chapters() {
    try {
      await api_call(edit_url, { cut_from }, 'PATCH')
      const href = seed_path(book_info.bslug, curr_seed.sname, _pgidx(cut_from))

      await goto(href)
    } catch (ex) {
      alert(ex.body.message)
    }
  }
</script>

<div class="form-group">
  <span class="form-field">
    <label class="form-label _inline" for="cut_from"
      >Cắt bỏ các chương từ chương thứ</label>
    <input
      id="cut_from"
      class="m-input _sm"
      type="number"
      min="1"
      max={cut_upto}
      bind:value={cut_from} />
  </span>

  <span class="form-field">
    <label class="form-label _inline" for="cut_upto">tới chương thứ</label>
    <input
      id="cut_upto"
      class="m-input _sm"
      type="number"
      min={cut_from}
      max={curr_seed.chmax}
      disabled
      bind:value={cut_upto} />
  </span>
  <span class="form-field _button">
    <button
      type="button"
      class="m-btn _warning _fill"
      disabled={!can_edit || cut_from < 0 || cut_from > curr_seed.chmax}
      on:click={cut_chapters}>
      <SIcon name="cut" />
      <span>Cắt bỏ</span>
    </button>
  </span>
</div>

<div class="explain">
  Xóa bỏ nội dung các chương từ chương thứ {cut_from} tới chương thứ {cut_upto}.
  Hãy kiểm tra kỹ trước khi thực hiện hành động, vì hành động này không thể đảo
  ngược.
</div>

<div class="explain _warn">
  Lưu ý: Hiện tại do hạn chế từ hệ thống, bạn chưa thể lựa chọn xóa một phần
  chương tiết, chỉ có thể xóa hết tới chương cuối cùng.
</div>

<style lang="scss">
  .form-group {
    display: flex;
    gap: 0.75rem;
    align-items: center;
    // text-align: center;
  }

  input {
    width: 4rem;
    text-align: center;
  }

  .explain {
    margin-top: 0.75rem;
    font-style: italic;
    @include fgcolor(tert);

    &._warn {
      @include fgcolor(warning);
    }
  }
</style>
