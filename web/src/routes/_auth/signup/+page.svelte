<script lang="ts">
  import { post_form, return_back } from '../shared'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { PageData } from './$types'

  export let data: PageData
  let email: string = data.email

  let uname = ''
  let upass = ''
  let error = ''

  const action = '/_db/_user/signup'

  async function submit(evt: Event) {
    evt.preventDefault()

    error = ''
    error = await post_form(action, { email, uname, upass })
    if (!error) return_back()
  }
</script>

<form {action} method="POST" on:submit={submit}>
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
    <label class="form-lbl" for="cname">Tên người dùng</label>
    <input
      class="m-input"
      type="text"
      id="cname"
      name="cname"
      placeholder="Tên người dùng"
      required
      bind:value={uname} />
  </div>

  <div class="form-inp">
    <label class="form-lbl" for="cpass">Mật khẩu</label>
    <input
      class="m-input"
      type="password"
      id="upass"
      name="upass"
      placeholder="Mật khẩu"
      required
      bind:value={upass} />
  </div>

  {#if error}<div class="form-msg _err">{error}</div> {/if}

  <footer class="form-btns">
    <button type="submit" class="m-btn _fill _lg _success">
      <SIcon name="user-plus" />
      <span class="-text">Tạo tài khoản</span>
    </button>
  </footer>
</form>

<div class="form-more">
  <a href="/_auth/login?email={email}" class="m-btn _text">
    <span class="-text">Đăng nhập</span>
  </a>
</div>
