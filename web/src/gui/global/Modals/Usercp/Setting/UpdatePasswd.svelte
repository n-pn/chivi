<script lang="ts">
  import { call_api } from '$lib/api_call'

  export let tab = 2

  let oldpw = ''
  let newpw = ''

  let error = ''

  async function submit() {
    error = ''

    const url = '/api/_self/passwd'
    const params = { oldpw, newpw }
    const [status, body] = await call_api(url, 'PUT', params, fetch)

    if (status < 400) tab = 0
    else error = body as string
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
      bind:value={oldpw} />
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
      bind:value={newpw} />
  </form-field>
</form-group>

{#if error}
  <div class="form-error">{error}</div>
{/if}

<footer class="form-action">
  <button
    type="submit"
    class="m-btn _harmful  _fill"
    on:click|preventDefault={submit}>
    <span>Đổi mật khẩu</span>
  </button>
</footer>
