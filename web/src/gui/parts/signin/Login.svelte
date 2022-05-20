<script lang="ts">
  import { call_api } from '$lib/api_call'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let email: string
  export let _form = 'login'

  let upass = ''
  let error: string

  const action_url = '/api/_user/log-in'

  async function submit() {
    const params = { email, upass }
    const [status, body] = await call_api(action_url, 'POST', params, fetch)

    if (status >= 400) error = body
    else window.location.reload()
  }
</script>

<form action={action_url} method="POST" on:submit|preventDefault={submit}>
  <div class="form-inp">
    <label class="form-lbl" for="email">Hòm thư</label>
    <input
      class="m-input "
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
      class="m-input "
      id="upass"
      name="upass"
      placeholder="Mật khẩu"
      required
      bind:value={upass} />
  </div>

  {#if error}<div class="form-msg _err">{error}</div>{/if}

  <footer class="form-btns">
    <button type="submit" class="m-btn _fill _lg _primary umami--click--login">
      <SIcon name="login" />
      <span class="-txt">Đăng nhập</span>
    </button>
  </footer>
</form>

<div class="form-more">
  <button class="m-btn _text _success" on:click={() => (_form = 'signup')}>
    <span class="-txt">Tài khoản mới</span>
  </button>

  <button class="m-btn _text" on:click={() => (_form = 'pwtemp')}
    ><span class="-txt">Quên mật khẩu</span></button>
</div>
