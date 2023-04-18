<script lang="ts">
  import type { Writable } from 'svelte/store'
  import { api_call } from '$lib/api_call'

  export let _user: Writable<App.CurrentUser>

  let form = { oldpw: '', newpw: '' }
  let error = ''

  async function submit() {
    error = ''

    try {
      await api_call('/_db/_self/passwd', form, 'PUT')
    } catch (ex) {
      error = ex.body.message
    }
  }
</script>

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
    disabled={$_user.privi < 0}
    on:click|preventDefault={submit}>
    <span>Đổi mật khẩu</span>
  </button>
</footer>
