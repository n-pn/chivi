<script>
  import { afterNavigate } from '$app/navigation'
  import Section from '$gui/sects/Section.svelte'

  afterNavigate(({ from }) => {
    let url = from?.url
    let back = '/'
    if (url && !url.pathname.startsWith('/_u')) back = url.toString()
    sessionStorage.setItem('back', back)
  })

  const tabs = [
    {
      type: 'login',
      href: `/_u/login`,
      icon: 'login',
      text: 'Đăng nhập',
    },
    {
      type: 'signup',
      href: `/_u/signup`,
      icon: 'user-plus',
      text: 'Tạo tài khoản',
    },
    {
      type: 'passwd',
      href: `/_u/passwd`,
      icon: 'key',
      text: 'Quên mật khẩu',
    },
  ]
</script>

<Section {tabs}>
  <header class="brand">
    <img class="blogo" src="/icons/chivi.svg" alt="logo" />
    <span class="btext">Chivi</span>
  </header>

  <section class="wrap">
    <article class=" island">
      <slot />
    </article>
  </section>
</Section>

<div class="form-msg u-warn">
  <strong>
    Lưu ý: Bạn cần thiết ủng hộ trang bằng tiền mặt để kích hoạt tài khoản.
  </strong>
</div>

<style lang="scss">
  .wrap {
    @include flex-ca;

    flex-direction: column;
    flex: 1;
    margin: 3rem 0;
  }

  article {
    width: 100%;
    max-width: 25rem;

    @include bdradi;
    @include border;
    padding: var(--gutter);
  }

  .brand {
    @include flex-ca;
    @include ftsize(x5);

    margin-top: 3rem;
    margin-bottom: 1.5rem;
    padding-right: 0.75rem;
  }

  .blogo {
    height: 3rem;
  }

  .btext {
    margin-left: 0.5rem;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }

  .form-msg {
    text-align: center;
  }
</style>
