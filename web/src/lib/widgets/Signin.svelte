<script>
  import { session } from '$app/stores'

  import { signin_user } from '$api/viuser_api'
  import SIcon from '$lib/blocks/SIcon.svelte'
  import Slider from './Slider.svelte'

  export let actived = false

  let params = { dname: '', email: '', upass: '' }

  let errs
  let type = 'login'

  async function submit(evt) {
    evt.preventDefault()
    errs = null

    const [_err, data] = await signin_user(fetch, type, params)
    if (_err) {
      errs = data
    } else {
      $session = data
      actived = false
    }
  }
</script>

<Slider bind:actived width={26}>
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="user" />
    </div>

    <div class="-text">Tài khoản</div>
  </svelte:fragment>

  <section class="inner">
    <div class="brand">
      <img src="/chivi-logo.svg" alt="logo" />
      <span class="-text">Chivi</span>
    </div>

    <form action="/api/{type}" method="POST" on:submit={submit}>
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

          <button type="submit" class="m-button _primary">
            <SIcon name="log-in" />
            <span class="-text">Đăng nhập</span>
          </button>
        {:else}
          <button
            type="button"
            class="m-button _text"
            on:click={() => (type = 'login')}>
            <span class="-text">Đăng nhập</span>
          </button>

          <button type="submit" class="m-button _success">
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

    @include flex($center: content);

    > .-text {
      margin-left: 0.5rem;
      @include font-size(8);
    }
  }

  form {
    display: block;
    width: 24rem;
    // margin: 0 auto;
    // margin-top: 20vh;
    max-width: 100%;
    @include border($sides: top);
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

    &:invalid {
      box-shadow: none;
    }

    &:focus {
      box-shadow: 0 0 1px 1px color(primary, 2);
    }

    &::placeholder {
      font-style: italic;
      @include fgcolor(neutral, 5);
    }
  }

  .errs {
    margin-bottom: 0.75rem;
    // text-align: center;
    @include fgcolor(harmful, 5);
    @include font-size(2);
  }

  footer {
    margin-top: 1.5rem;

    @include flex($center: content);

    button {
      @include truncate(null);
    }

    button + button {
      margin-left: 1rem;
    }
  }
</style>
