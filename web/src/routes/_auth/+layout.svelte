<script>
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  $: $crumbs = [{ text: 'Cổng đăng nhập' }]

  import { afterNavigate } from '$app/navigation'
  import Section from '$gui/sects/Section.svelte'

  afterNavigate(({ from }) => {
    let url = from?.url
    let back = '/'
    if (url && !url.pathname.startsWith('/_auth')) back = url.toString()
    sessionStorage.setItem('back', back)
  })

  const tabs = [
    {
      type: 'login',
      href: `/_auth/login`,
      icon: 'login',
      text: 'Đăng nhập',
    },
    {
      type: 'signup',
      href: `/_auth/signup`,
      icon: 'user-plus',
      text: 'Tạo tài khoản',
    },
    {
      type: 'passwd',
      href: `/_auth/passwd`,
      icon: 'key',
      text: 'Quên mật khẩu',
    },
  ]
</script>

<header class="brand">
  <img class="blogo" src="/icons/chivi.svg" alt="logo" />
  <span class="btext">Chivi</span>
</header>

<Section {tabs}>
  <section class="wrap">
    <article class=" island">
      <slot />
    </article>
  </section>
</Section>

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
    @include ftsize(x4);

    // font-weight: 300;
    line-height: 2.5rem;
    margin-top: 2rem;
    margin-bottom: 1.5rem;
    padding-right: 0.75rem;
  }

  .blogo {
    height: 2.5rem;
  }

  .btext {
    margin-left: 0.5rem;
    letter-spacing: 0.2em;
    text-transform: uppercase;
  }
</style>
