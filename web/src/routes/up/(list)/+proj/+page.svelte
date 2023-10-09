<script lang="ts">
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let uform = data.uform
  let labels = (uform.labels || []).join(', ')

  let err_text: string

  const action = '/_rd/upstems'

  async function submit() {
    const body = { ...uform, labels: labels.split(',') }

    try {
      const { sname, id } = await api_call(action, body, 'POST')
      await goto(`/up/${sname}:${id}`)
    } catch (ex) {
      err_text = ex.body.message
    }
  }

  const tl_zname = async () => {
    const res = await fetch(`/_sp/hname?input=${uform.zname}`)
    uform.vname = await res.text()
  }

  const tl_intro = async () => {
    const url = `/_m1/qtran?format=txt`
    const headers = { 'Content-Type': 'text/plain' }
    const res = await fetch(url, {
      method: 'POST',
      body: uform.vintro,
      headers,
    })
    uform.vintro = await res.text()
  }
</script>

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
        bind:value={uform.zname} />
    </form-field>

    <form-field>
      <label class="form-label" for="vname">Tên tiếng Việt</label>
      <input
        type="text"
        class="m-input"
        name="vname"
        placeholder="Để trắng để hệ thống tự gợi ý"
        bind:value={uform.vname} />
    </form-field>
  </form-group>

  <div class="form-group vintro">
    <div class="form-label">
      <label for="vintro">Giới thiệu tiếng Việt</label>
      <button type="button" disabled={!uform.vintro} on:click={tl_intro}
        >Dịch nhanh</button>
    </div>
    <textarea
      class="m-input"
      name="vintro"
      rows="8"
      bind:value={uform.vintro} />
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
        bind:value={uform.wn_id} />
    </form-field>
  </div>

  {#if err_text}<div class="form-msg _err">{err_text}</div>{/if}

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
</form>

<style lang="scss">
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
</style>
