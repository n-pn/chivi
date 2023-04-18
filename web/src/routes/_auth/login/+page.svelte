<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  import { post_form, return_back } from '../shared'

  export let data: PageData
  let email: string = data.email

  let upass = ''
  let error: string

  const action = '/_db/_user/log-in'

  const submit = async () => {
    error = ''
    error = await post_form(action, { email, upass })
    if (!error) return_back()
  }
</script>

<form {action} method="POST" on:submit|preventDefault={submit}>
  <div class="form-inp">
    <label class="form-lbl" for="email">Hòm thư</label>
    <input
      class="m-input"
      type="email"
      id="email"
      name="email"
      placeholder="Hòm thư"
      required
      bind:value={email} />
  </div>

  <div class="form-inp">
    <label class="form-lbl" for="cpass">Mật khẩu</label>
    <input
      type="password"
      class="m-input"
      id="upass"
      name="upass"
      placeholder="Mật khẩu"
      required
      bind:value={upass} />
  </div>

  {#if error}<div class="form-msg _err">{error}</div>{/if}

  <footer class="form-btns">
    <button type="submit" class="m-btn _fill _lg _primary">
      <SIcon name="login" />
      <span class="-txt">Đăng nhập</span>
    </button>
  </footer>
</form>

<div class="form-more">
  <a href="/_auth/signup?email={email}" class="m-btn _text _success">
    <span class="-txt">Tài khoản mới</span>
  </a>

  <a href="/_auth/passwd?email={email}" class="m-btn _text">
    <span class="-txt">Quên mật khẩu</span>
  </a>
</div>
