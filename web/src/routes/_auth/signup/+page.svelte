<script lang="ts">
  import { post_form, return_back } from '../shared'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import type { PageData } from './$types'

  export let data: PageData

  let uform = {
    email: data.email,
    uname: '',
    upass: '',
    rcode: '',
  }

  let error = ''

  const action = '/_db/_user/signup'

  async function submit(evt: Event) {
    error = ''
    evt.preventDefault()
    error = await post_form(action, uform)
    if (!error) return_back()
  }
</script>

<form {action} method="POST" on:submit={submit}>
  <div class="form-inp">
    <label class="form-lbl" for="email">Hòm thư</label>
    <input
      class="m-input"
      type="email"
      name="email"
      placeholder="Địa chỉ email của bạn"
      required
      bind:value={uform.email} />
  </div>

  <div class="form-inp">
    <label class="form-lbl" for="cname">Tên người dùng</label>
    <input
      class="m-input"
      type="text"
      name="cname"
      placeholder="Tên hiển thị của bạn"
      required
      bind:value={uform.uname} />
  </div>

  <div class="form-inp">
    <label class="form-lbl" for="cpass">Mật khẩu</label>
    <input
      class="m-input"
      type="password"
      name="upass"
      placeholder="Mật khẩu cần ít nhất 8 ký tự"
      required
      bind:value={uform.upass} />
  </div>

  <div class="form-inp">
    <label class="form-lbl" for="rcode">Mã giới thiệu</label>
    <input
      class="m-input"
      type="text"
      name="rcode"
      placeholder="Mã giới thiệu từ người dùng (có thể để trắng)"
      bind:value={uform.rcode} />
  </div>

  {#if error}<div class="form-msg _err">{error}</div> {/if}

  <footer class="form-btns">
    <button
      type="submit"
      class="m-btn _fill _lg _success"
      data-umami-event="create-account">
      <SIcon name="user-plus" />
      <span class="-text">Tạo tài khoản</span>
    </button>
  </footer>
</form>
