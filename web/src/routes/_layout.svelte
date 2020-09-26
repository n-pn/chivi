<script>
  import { stores } from '@sapper/app'
  const { page } = stores()

  export let segment = ''

  $: {
    if (typeof gtag === 'function') {
      window.gtag('config', 'UA-160000714-1', {
        page_path: $page.path,
      })
    }
  }

  import { onMount } from 'svelte'
  import { self_uname, self_power } from '$src/stores'

  onMount(async () => {
    const res = await fetch('/_self')
    const data = await res.json()

    if (data._stt == 'ok') {
      $self_uname = data.uname
      $self_power = data.power
    }
  })
</script>

<div>
  <slot {segment} />
</div>

<footer>
  <span>
    Trang web đang trong quá trình hoàn thiện, mọi ý kiến thắc mắc mời liên hệ
    tới một trong các địa chỉ sau:
  </span>

  <a
    class="link"
    href="https://voz.vn/t/truyen-tau-dich-may-mtl.95881/"
    target="_blank"
    rel="noreferer noopener">
    Vozforums
  </a>

  <a
    class="link"
    href="https://www.facebook.com/chivi.xyz/"
    target="_blank"
    rel="noreferer noopener">
    Facebook
  </a>

  <a
    class="link"
    href="https://discord.gg/mdC3KQH"
    target="_blank"
    rel="noreferer noopener">
    Discord
  </a>
</footer>

<style lang="scss">
  :global(html),
  :global(body),
  :global(#sapper),
  :global(main) {
    min-height: 100%;
  }

  :global(#sapper) {
    min-width: 320px;
    display: flex;
    flex-direction: column;
  }

  div {
    flex: 1;
  }

  footer {
    width: 100%;
    text-align: center;
    padding: 0.75rem;
    @include font-size(2);
    @include fgcolor(neutral, 6);
    @include bgcolor(neutral, 2);
    @include border($sides: top);
  }

  .link {
    margin-left: 0.375rem;
    font-weight: 500;
    @include fgcolor(primary, 6);
    &:hover {
      @include fgcolor(primary, 4);
    }
  }

  // :global([data-kbd]) {
  //   position: relative;

  //   &:after {
  //     display: none;
  //   }

  //   @include hover {
  //     &:after {
  //       display: inline-block;
  //       position: absolute;
  //       content: attr(data-kbd);

  //       top: 0.375rem;
  //       right: 0.375rem;

  //       font-weight: 500;
  //       text-transform: uppercase;
  //       text-align: baseline;
  //       line-height: 1rem;
  //       // height: 1rem;
  //       overflow: hidden;

  //       margin: 0;
  //       padding: 0 0.25rem;

  //       @include font-size(2);
  //       @include fgcolor(neutral, 6);
  //       @include bgcolor(yellow, 1);
  //       @include border();
  //       @include shadow(3);
  //       @include radius();
  //     }
  //   }
  // }
</style>
