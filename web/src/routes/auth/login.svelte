<script>
  import SvgIcon from '$atoms/SvgIcon'
  import Vessel from '$parts/Vessel'

  import { self_dname, self_power } from '$src/stores'

  let email = ''
  let upass = ''
  let error

  async function submit(evt) {
    evt.preventDefault()

    error = null

    const res = await fetch('api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, upass }),
    })

    if (res.ok) {
      const data = await res.json()

      $self_dname = data.dname
      $self_power = data.power
      _goto_('/')
    } else {
      error = true
    }
  }
</script>

<Vessel>
  <section>
    <form action="/_login" method="POST" on:submit={submit}>
      <header>
        <img src="/chivi-logo.svg" alt="logo" />
        <span>Chivi</span>
      </header>

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
        <div class="error">Email hoặc mật khẩu không đúng!</div>
      {/if}

      <footer>
        <a href="/auth/signup" class="m-button _line">
          <span>Tài khoải mới</span>
        </a>

        <button type="submit" class="m-button _primary login">
          <SvgIcon name="log-in" />
          <span>Đăng nhập</span>
        </button>
      </footer>
    </form>
  </section>
</Vessel>

<style lang="scss">
  section {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 700;
    @include bgcolor(neutral, 3, 0.3);
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
    @include flex-gap($gap: 0.5, $child: ':global(*)');
    @include border($sides: bottom);
    @include font-size(7);
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
