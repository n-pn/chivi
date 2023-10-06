<script lang="ts">
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let form = { ...data.form }
  let labels = (form.labels || []).join(', ')

  let errors: string

  $: owner =
    form.viuser_id == 0 || form.viuser_id == $_user.vu_id || $_user.vu_id > 3

  const action = '/_up/stems'

  async function submit() {
    const action = form.id ? `/_up/stems/${form.id}` : '/_up/stems'
    const body = { ...form, labels: labels.split(',') }

    try {
      const { sname, id } = await api_call(action, body, 'POST')
      await goto(`/up/${sname}:${id}`)
    } catch (ex) {
      errors = ex.body.message
    }
  }

  const tl_zname = async () => {
    const res = await fetch(`/_sp/hname?input=${form.zname}`)
    form.vname = await res.text()
  }

  const tl_intro = async () => {
    const url = `/_m1/qtran?format=txt`
    const headers = { 'Content-Type': 'text/plain' }
    const res = await fetch(url, { method: 'POST', body: form.vintro, headers })
    form.vintro = await res.text()
  }

  const delete_project = async () => {
    const res = await fetch(`/_up/stems/${form.id}`, { method: 'DELETE' })

    if (res.ok) goto('/up')
    else errors = await res.text()
  }

  let confirm: number
</script>

<header>
  <div class="m-chip _primary">Thêm/sửa tay</div>
</header>

<form {action} method="POST" on:submit|preventDefault={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="zname">Tên tiếng Trung</label>
      <input
        type="text"
        class="m-input"
        name="zname"
        placeholder="Tên gốc tiếng trung"
        on:change={tl_zname}
        required
        bind:value={form.zname} />
    </form-field>

    <form-field>
      <label class="form-label" for="vname">Tên tiếng Việt</label>
      <input
        type="text"
        class="m-input"
        name="vname"
        placeholder="Để trắng để hệ thống tự gợi ý"
        bind:value={form.vname} />
    </form-field>
  </form-group>

  <div class="form-group vintro">
    <div class="form-label">
      <label for="vintro">Giới thiệu tiếng Việt</label>
      <button type="button" disabled={!form.vintro} on:click={tl_intro}
        >Dịch nhanh</button>
    </div>
    <textarea class="m-input" name="vintro" rows="8" bind:value={form.vintro} />
  </div>

  <div class="form-group labels">
    <label class="label" for="labels">Nhãn truyện</label>
    <input
      type="text"
      class="m-input"
      name="labels"
      placeholder="Các nhãn để tìm kiếm"
      bind:value={labels} />
    <p class="hints">
      Gợi ý: 1. Tách các nhãn bằng dấu phẩy (,) 2.Các nhãn bằng tiếng Trung sẽ
      được tự đổi sang tiếng Việt
    </p>
  </div>

  <div class="form-group">
    <form-field>
      <label class="label" for="book_id">Liên kết tới bộ truyện:</label>
      <input
        type="number"
        class="m-input"
        name="book_id"
        placeholder="ID bộ truyện"
        bind:value={form.wninfo_id} />
    </form-field>
  </div>

  {#if errors}
    <div class="form-msg _err">{errors}</div>
  {/if}

  <footer class="action">
    <button
      class="m-btn _primary _fill _lg"
      type="submit"
      disabled={$_user.privi < 1}>
      <SIcon name="send" />
      <span class="-txt">Lưu thông tin</span>
      <SIcon name="privi-1" iset="icons" />
    </button>
  </footer>

  {#if form.id}
    <footer class="delete">
      <h3>Xóa dự án</h3>
      <p class="hints">Nhập vào ID của dự án để khẳng định việc xóa dự án:</p>

      <div class="delete-input">
        <input
          type="number"
          class="m-input"
          placeholder="ID dự án"
          bind:value={confirm} />
        <button
          type="button"
          class="m-btn _harmful _fill"
          disabled={!owner || confirm != form.id}
          on:click={delete_project}>
          <SIcon name="eraser" />
          <span class="-txt">Xóa dự án</span>
        </button>
      </div>
    </footer>
  {/if}
</form>

<style lang="scss">
  header {
    @include border($loc: bottom);
    padding-bottom: var(--gutter-small);
    margin: var(--gutter) 0;
  }

  .label {
    display: block;
    font-weight: 500;
    margin-bottom: 0.5rem;
  }

  .m-input {
    display: block;
    width: 100%;
  }

  .form-group {
    margin-top: 0.75rem;
  }

  .vintro {
    margin-top: 1rem;

    .form-label {
      display: flex;
    }

    button {
      margin-left: auto;
      background: none;
      @include fgcolor(tert);
      font-style: italic;
    }
  }

  .hints {
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1rem;
    margin-top: 0.5rem;
  }

  .action {
    @include flex();
    justify-content: right;
    margin: 0.75rem 0;
  }

  .delete {
    padding: 0.75rem 0;
    @include border(--bd-soft, $loc: top);

    .hints {
      margin-bottom: 0.5rem;
    }
  }

  .delete-input {
    display: flex;
    gap: 0.5rem;

    input {
      width: 10rem;
    }
  }
</style>
