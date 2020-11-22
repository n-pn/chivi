<script>
  import SvgIcon from '$atoms/SvgIcon'
  import Vessel from '$parts/Vessel'

  import { self_uname, self_power } from '$src/stores'

  let email = ''
  let uname = ''
  let upass = ''
  let error

  async function submit(evt) {
    error = null

    const res = await fetch('_signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, uname, upass }),
    })

    const data = await res.json()

    if (data._stt == 'ok') {
      $self_uname = data.uname
      $self_power = data.power
      _goto_('/')
    } else {
      error = error_message(data._msg)
    }
  }

  function error_message(message) {
    switch (message) {
      case 'email too short':
      case 'invalid email format':
        return 'Địa chỉ hòm thư không hợp lệ'
      case 'email existed':
        return 'Địa chỉ hòm thư đã được sử dụng'
      case 'username too short':
        return 'Tên người dùng quá ngắn (cần ít nhất 5 ký tự)'
      case 'invalid username format':
        return 'Tên người dùng không hợp lệ'
      case 'username existed':
        return 'Tên người dùng đã được sử dụng'
      case 'password too short':
        return 'Mật khẩu quá ngắn (cần ít nhất 7 ký tự)'
      default:
        return 'Không rõ lỗi, xin liên hệ ban quản trị'
    }
  }
</script>

<Vessel>
  <section>
    <form action="/_login" method="POST" on:submit|preventDefault={submit}>
      <header><img src="/logo.svg" alt="logo" /><span>Chivi</span></header>

      <div class="input">
        <label for="email">Hòm thư</label>
        <input
          type="email"
          id="email"
          name="email"
          placeholder="Hòm thư"
          required
          bind:value={email} />
      </div>

      <div class="input">
        <label for="cname">Tên người dùng</label>
        <input
          type="text"
          id="cname"
          name="cname"
          placeholder="Tên người dùng"
          required
          bind:value={uname} />
      </div>

      <div class="input">
        <label for="cpass">Mật khẩu</label>
        <input
          type="password"
          id="upass"
          name="upass"
          placeholder="Mật khẩu"
          required
          bind:value={upass} />
      </div>

      {#if error}
        <div class="error">{error}</div>
      {/if}

      <footer>
        <a href="/auth/login" class="m-button _line">
          <span>Đăng nhập</span>
        </a>

        <button type="submit" class="m-button _success login">
          <SvgIcon name="user-plus" />
          <span>Tạo tài khoản</span>
        </button>
      </footer>
    </form>
  </section>
</Vessel>

<style lang="scss">
  section {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 700;
    background: color(neutral, 3, 0.3);
    @include flex($center: both);
  }

  form {
    display: block;
    width: 24rem;
    // margin: 0 auto;
    // margin-top: 20vh;
    max-width: 100%;
    padding: 0 1.5rem;
    @include bgcolor(#fff);
    @include shadow(3);
    @include radius();
  }

  header {
    line-height: 2.5rem;
    font-weight: 300;
    padding: 1.5rem 1rem 0.5rem 0;
    @include flex($center: both);
    @include border($sides: bottom);
    @include font-size(7);

    // > * {
    //   @include flex-gap($gap: 0.5rem);
    // }
  }

  .input {
    margin: 0.75rem 0;
  }

  label {
    display: block;
    text-transform: uppercase;
    font-weight: 500;
    line-height: 1.5rem;
    margin-bottom: 0.25rem;
    @include font-size(1);
    @include fgcolor(neutral, 6);
  }

  input {
    display: block;
    width: 100%;
    padding: 0.375rem 0.75rem;

    @include border();
    @include radius();

    &:focus,
    &:hover {
      @include bdcolor($color: primary, $shade: 3);
    }

    &:focus {
      box-shadow: 0 0 1px 1px color(primary, 2);
    }

    &::placeholder {
      font-style: italic;
      @include fgcolor(neutral, 5);
    }
  }

  .error {
    margin-bottom: 0.75rem;
    // text-align: center;
    @include fgcolor(harmful, 5);
    @include font-size(2);
  }

  footer {
    // @include border($sides: top);
    // margin-top: 1.5rem;
    padding: 0.75rem 0 1.5rem;

    @include flex;

    .login {
      margin-left: auto;
    }
  }
</style>
