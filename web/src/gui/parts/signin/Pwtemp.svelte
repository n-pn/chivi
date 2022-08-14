<script context="module" lang="ts">
  import { call_api } from '$lib/api_call'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let email: string
  export let _form = 'pwtemp'

  let msg_type: '' | 'ok' | 'err' = ''
  let msg_text = ''

  const action_url = '/api/_user/pwtemp'

  async function submit() {
    msg_type = ''
    msg_text = ''

    const [status, body] = await call_api(action_url, 'POST', { email }, fetch)

    if (status >= 400) {
      msg_type = 'err'
      msg_text = body
    } else {
      msg_type = 'ok'
    }
  }
</script>

<form action={action_url} method="POST" on:submit|preventDefault={submit}>
  <div class="form-inp">
    <label class="form-lbl" for="email">Hòm thư</label>
    <input
      type="email"
      class="m-input _lg"
      id="email"
      name="email"
      placeholder="Hòm thư"
      required
      bind:value={email} />
  </div>

  {#if msg_type == 'err'}
    <div class="form-msg _err">{msg_text}</div>
  {:else if msg_type == 'ok'}
    <div class="form-msg _ok">
      <p>Một mật khẩu tạm thời đã được gửi tới hòm thư của bạn</p>
      <p>Check thử trong thư mục Spam nếu không thấy hiện trong inbox.</p>
    </div>
  {/if}

  <footer class="form-btns">
    <button type="submit" class="m-btn _fill _warning">
      <SIcon name="key" />
      <span class="-txt">Gửi mật khẩu</span>
    </button>
  </footer>
</form>

<div class="form-more">
  <button class="m-btn _text" on:click={() => (_form = 'login')}>
    <span class="-text">Đăng nhập</span>
  </button>

  <button class="m-btn _text _success" on:click={() => (_form = 'signup')}>
    <span class="-txt">Tài khoản mới</span>
  </button>
</div>
