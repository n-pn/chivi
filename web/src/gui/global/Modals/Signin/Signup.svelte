<script lang="ts">
  import { api_call } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let email: string = ''
  export let _form: string = 'signup'

  let uname = ''
  let upass = ''
  let error = ''

  const action_url = '/api/_user/signup'

  async function submit() {
    error = ''

    try {
      await api_call(action_url, { email, uname, upass }, 'POST')
      const back = sessionStorage.getItem('back') || '/'
      window.location.href = back
    } catch (ex) {
      console.log(ex)
      error = ex.message
    }
  }
</script>

<form action={action_url} method="POST" on:submit|preventDefault={submit}>
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
  <a href="/_auth/login" class="m-btn _text" on:click={() => (_form = 'login')}>
    <span class="-text">Đăng nhập</span>
  </a>
</div>
