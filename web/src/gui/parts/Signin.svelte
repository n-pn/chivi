<script context="module" lang="ts">
  import { api_call } from '$lib/api_call'

  class Params {
    dname = ''
    email = ''
    upass = ''
  }

  export async function signin_user(type: string, params: Params) {
    const [stt, msg] = await api_call(fetch, `user/${type}`, params, 'POST')
    return stt < 400 ? '' : (msg as string)
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  export let actived = false
  export let params = new Params()

  let type = 'login'
  let errs: string

  async function submit() {
    errs = ''
    errs = await signin_user(type, params)
    if (!errs) window.location.reload()
  }
</script>

<Slider class="signin" bind:actived _rwidth={26}>
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

    <form
      action="/api/user/{type}"
      method="POST"
      on:submit|preventDefault={submit}>
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
        <button
          class="m-btn _text"
          on:click={() => (type = type == 'login' ? 'signup' : 'login')}>
          <span class="-text"
            >{type == 'login' ? 'Tài khoản mới' : 'Đăng nhập'}</span>
        </button>

        <button
          type="submit"
          class="m-btn _fill {type == 'login'
            ? '_primary'
            : '_success'} umami--click--{type}">
          <SIcon name="login" />
          <span class="-text"
            >{type == 'login' ? 'Đăng nhập' : 'Tạo tài khoản'}</span>
        </button>
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
