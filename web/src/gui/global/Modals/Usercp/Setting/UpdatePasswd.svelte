<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'

  export let _user: Writable<App.CurrentUser>

  let form = { oldpw: '', newpw: '' }
  let error = ''

  const action = '/_db/_self/passwd'
  async function submit(evt: Event) {
    evt.preventDefault()
    error = ''

    try {
      await api_call(action, form, 'PUT')
    } catch (ex) {
      error = ex.body.message
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

  {#if error}
    <div class="form-error">{error}</div>
  {/if}

  <footer class="form-action">
    <button
      type="submit"
      class="m-btn _harmful _fill"
      disabled={$_user.privi < 0}>
      <span>Đổi mật khẩu</span>
    </button>
  </footer>
</form>
