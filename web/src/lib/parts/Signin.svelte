<script context="module">
  export async function signin_user(type, params) {
    const res = await fetch(`/api/user/${type}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (!res.ok) return [res.status, await res.text()]
    return [0, await res.json()]
  }
</script>

<script>
  import { session } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Slider from '$molds/Slider.svelte'

  export let actived = false

  let params = { dname: '', email: '', upass: '' }

  let errs
  let type = 'login'

  async function submit(evt) {
    evt.preventDefault()
    errs = null

    const [_err, data] = await signin_user(type, params)
    if (_err) {
      errs = data
    } else {
      $session = data
      actived = false
    }
  }
</script>

<Slider bind:actived _rwidth={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>

    <div class="-text">Tài khoản</div>
  </svelte:fragment>

  <section class="inner">
    <div class="brand">
      <img src="/icons/chivi.svg" alt="logo" />
      <span class="-text">Chivi</span>
    </div>

    <form action="/api/user/{type}" method="POST" on:submit={submit}>
      {#if type == 'signup'}
        <div class="input">
          <label for="cname">Tên người dùng</label>
          <input
            type="text"
            id="cname"
            name="cname"
            placeholder="Tên người dùng"
            required
            bind:value={params.dname} />
        </div>
      {/if}

      <div class="input">
        <label for="email">Hòm thư</label>
        <input
          type="email"
          id="email"
          name="email"
          placeholder="Hòm thư"
          required
          bind:value={params.email} />
      </div>

      <div class="input">
        <label for="cpass">Mật khẩu</label>
        <input
          type="password"
          id="upass"
          name="upass"
          placeholder="Mật khẩu"
          required
          bind:value={params.upass} />
      </div>

      {#if errs}
        <div class="errs">{errs}</div>
      {/if}

      <footer>
        {#if type == 'login'}
          <button
            type="button"
            class="m-button _text"
            on:click={() => (type = 'signup')}>
            <span class="-text">Tài khoản mới</span>
          </button>

          <button type="submit" class="m-button _primary _fill">
            <SIcon name="login" />
            <span class="-text">Đăng nhập</span>
          </button>
        {:else}
          <button
            type="button"
            class="m-button _text"
            on:click={() => (type = 'login')}>
            <span class="-text">Đăng nhập</span>
          </button>

          <button type="submit" class="m-button _success _fill">
            <SIcon name="user-plus" />
            <span class="-text">Tạo tài khoản</span>
          </button>
        {/if}
      </footer>
    </form>
  </section>
</Slider>

<style lang="scss">
  .inner {
    width: 24rem;
    max-width: 100%;
    margin: 0 auto;
    margin-top: 20vh;
    padding: 1rem;
  }

  .brand {
    // font-weight: 300;
    line-height: 2.5rem;
    margin-bottom: 1rem;
    padding-right: 1rem;

    @include flex($center: horz);

    > .-text {
      margin-left: 0.5rem;
      @include ftsize(x3);
    }
  }

  form {
    display: block;
    width: 24rem;
    // margin: 0 auto;
    // margin-top: 20vh;
    max-width: 100%;
    @include border(--bd-main, $loc: top);
  }

  .input {
    margin: 0.75rem 0;
  }

  label {
    display: block;
    // text-transform: uppercase;
    font-weight: 500;
    line-height: 1.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(md);
    @include fgcolor(neutral, 5);
  }

  input {
    display: block;
    width: 100%;
    border: 0;
    outline: 0;
    padding: 0.375rem 0.75rem;
    line-height: 1.75rem;
    @include ftsize(lg);

    @include linesd(--bd-main);
    @include bdradi();

    &:hover {
      @include linesd(primary, 4, 1px);
    }

    &:focus {
      @include linesd(primary, 4, 2px);
    }

    &::placeholder {
      font-style: italic;
      color: var(--color-gray-5);
    }
  }

  .errs {
    margin-bottom: 0.75rem;
    // text-align: center;
    @include fgcolor(harmful, 5);
    @include ftsize(sm);
  }

  footer {
    margin-top: 1.5rem;

    @include flex($center: horz);

    button {
      @include clamp($width: null);
    }

    button + button {
      margin-left: 1rem;
    }
  }
</style>
