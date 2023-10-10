<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let _user: Writable<App.CurrentUser>

  let form = { oldpw: '', newpw: '' }

  let msg_type = ''
  let msg_text = ''

  const action = '/_db/_self/passwd'
  async function submit(evt: Event) {
    evt.preventDefault()
    msg_type = msg_text = ''

    try {
      await api_call(action, form, 'PUT')
      msg_type = '_ok'
      msg_text = 'Bạn đã đổi mật khẩu thành công!'
    } catch (ex) {
      msg_type = '_err'
      msg_text = ex.body.message
    }
  }
</script>

<form {action} method="PUT" on:submit={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="upass">Mật khẩu cũ</label>
      <input
        type="password"
        class="m-input"
        name="upass"
        placeholder="Có thể dùng mật khẩu tạm thời"
        required
        bind:value={form.oldpw} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="new_upass">Mật khẩu mới</label>
      <input
        type="password"
        class="m-input"
        name="new_upass"
        placeholder="Ít nhất 8 ký tự"
        required
        bind:value={form.newpw} />
    </form-field>
  </form-group>

  <div class="form-msg {msg_type}">{msg_text}</div>

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _harmful _fill"
      disabled={$_user.privi < 0}>
      <SIcon name="device-floppy" />
      <span>Đổi mật khẩu</span>
    </button>
  </footer>
</form>
