<script>
  import { user } from '$src/stores'

  let email = ''
  let upass = ''
  let error

  async function submit(evt) {
    error = null

    const res = await fetch('_login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, upass }),
    })

    const data = await res.json()

    console.log({ data })

    if (data.status == 'ok') {
      $user = { uname: data.uname, power: data.power }
      _goto('/')
    } else {
      error = true
    }
  }
</script>

<style lang="scss">
  section {
    display: block;
    height: 100vh;
  }

  header {
    text-align: center;
    @include border($sides: bottom);

    h2 {
      height: 3rem;
      // @include fgcolor(primary, 7);
      @include font-size(7);
      font-weight: 300;
    }
  }

  form {
    display: block;
    width: 20rem;
    margin: 0 auto;
    margin-top: 20vh;
    max-width: 100%;
    padding: 0.75rem 1.5rem;
    @include bgcolor(#fff);
    @include shadow(3);
    @include radius();
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
    @include fgcolor(neutral, 5);
  }

  input {
    display: block;
    width: 100%;
    padding: 0.375rem 0.75rem;

    @include border();
    @include radius();
    &:focus,
    &:active {
      @include bdcolor($color: primary, $shade: 3);
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
    text-align: right;
  }
</style>

<section>
  <form action="/_login" method="POST" on:submit|preventDefault={submit}>
    <header>
      <h2>Chivi</h2>
    </header>

    <div class="input">
      <label for="email">Email</label>
      <input
        type="email"
        id="email"
        name="email"
        placeholder="Email"
        bind:value={email} />
    </div>

    <div class="input">
      <label for="cpass">Mật khẩu</label>
      <input
        type="password"
        id="upass"
        name="upass"
        placeholder="Mật khẩu"
        bind:value={upass} />
    </div>

    {#if error}
      <div class="error">Email hoặc mật khẩu không đúng!</div>
    {/if}

    <footer>
      <button type="submit" class="m-button _primary">Đăng nhập</button>
    </footer>
  </form>

</section>
