<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import { post_form } from '../shared'
  import type { PageData } from './$types'

  export let data: PageData
  let email: string = data.email
  let msg_type: '' | 'ok' | 'err' = ''
  let msg_text = ''

  const action = '/_db/_user/pwtemp'

  async function submit(evt: Event) {
    evt.preventDefault()

    msg_type = ''
    msg_text = ''

    msg_text = await post_form(action, { email })
    msg_type = msg_text ? 'err' : 'ok'
  }
</script>

<form {action} method="POST" on:submit={submit}>
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
      <p>Một mật khẩu tạm thời đã được gửi tới hòm thư của bạn.</p>
      <p>Mật khẩu này sẽ có hiệu lực trong vòng 5 phút.</p>
    </div>
  {/if}

  <footer class="form-btns">
    <button
      type="submit"
      class="m-btn _fill _warning"
      data-umami-event="reset-passwd">
      <SIcon name="key" />
      <span class="-txt">Gửi mật khẩu</span>
    </button>
  </footer>
</form>

<div class="form-more">
  <a href="/_auth/login?email={email}" class="m-btn _text">
    <span class="-text">Đăng nhập</span>
  </a>

  <a href="/_auth/signup?email={email}" class="m-btn _text _success">
    <span class="-txt">Tài khoản mới</span>
  </a>
</div>
