<script lang="ts">
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let curr_seed: CV.Chroot

  export let can_edit = false
  export let edit_url: string

  export let bslug: string

  let confirm = ''

  async function delete_seed() {
    try {
      await api_call(edit_url, {}, 'DELETE')
      goto(`/wn/${bslug}/ch~avail`)
    } catch (ex) {
      alert(ex.body.message)
    }
  }

  const system_seeds = ['~avail', '~chivi']
  $: can_delete = can_edit && !system_seeds.includes(curr_seed.sname)
</script>

<div class="form-group">
  <span class="form-field">
    <label class="form-label" for="delete_seed"
      >Gõ vào <em>&ldquo;{curr_seed.sname}&rdquo;</em> để đảm bảo:</label>
    <input type="text" id="delete_seed" class="m-input" bind:value={confirm} />
  </span>

  <span class="form-field _button">
    <button
      type="button"
      class="m-btn _harmful _fill"
      on:click={delete_seed}
      disabled={!can_delete || confirm != curr_seed.sname}>
      <SIcon name="trash" />
      <span>Xoá danh sách</span>
    </button>
  </span>
</div>

<div class="explain">
  Xóa bỏ hoàn toàn danh sách chương tiết. Lưu ý, để tránh nhầm lẫn đáng tiếc thì
  hành động này chỉ xóa thông tin danh sách chương, nội dung chương tiết vẫn
  được giữ nguyên. Bạn có thể liên hệ ban quản trị nếu muốn khắc phục.
</div>

<style lang="scss">
  .form-group {
    display: flex;
    gap: 0.75rem;
    align-items: flex-end;
  }

  input {
    width: 100%;
  }

  .explain {
    margin-top: 0.75rem;
    font-style: italic;
    @include fgcolor(tert);
  }
</style>
