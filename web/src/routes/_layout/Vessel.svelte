<script>
  import { user } from '$src/stores'
  import MIcon from '$mould/MIcon.svelte'

  export let segment = ''
  export let shift = false
  export let clear = false

  async function logout() {
    $user = { uname: 'Guest', power: -1 }
    const res = await fetch('_logout')
  }

  let lastScrollTop = 0

  // Credits: "https://github.com/qeremy/so/blob/master/so.dom.js#L426"
  function handleScroll(evt) {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop

    const scrollDown = scrollTop > lastScrollTop
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop

    clear = scrollDown
  }
</script>

<svelte:window on:scroll={handleScroll} />

<div class="vessel" class:_shift={shift} class:__clear={clear}>
  <header class="header" data-page={segment}>
    <nav class="center -wrap">
      <div class="-left">
        <a href="/" class="header-item _brand">
          <img src="/logo.svg" alt="logo" />
          <span class="header-text _show-md">Chivi</span>
        </a>

        <slot name="header-left" />
      </div>

      <div class="-right">
        <slot name="header-right" />

        <span class="header-item _menu">
          <MIcon class="m-icon _user" name="user" />
          <span class="header-text _show-md">
            {$user.power < 0 ? 'Khách' : $user.uname}
          </span>

          <div class="header-menu">
            <div class="-head">
              <MIcon class="m-icon _user" name="user" />
              <span class="-uname">{$user.uname}</span>
            </div>

            {#if $user.power < 0}
              <a href="/auth/login" class="-item">
                <MIcon class="m-icon _log-in" name="log-in" />
                <span>Đăng nhập</span>
              </a>
              <a href="/auth/signup" class="-item">
                <MIcon class="m-icon _user-plus" name="user-plus" />
                <span>Đăng ký</span>
              </a>
            {:else}
              <a
                href="/auth/logout"
                class="-item"
                on:click|preventDefault={logout}>
                <MIcon class="m-icon _log-out" name="log-out" />
                <span>Đăng xuất</span>
              </a>
            {/if}
          </div>
        </span>
      </div>
    </nav>
  </header>

  <main>
    <div class="center">
      <slot />
    </div>
  </main>
</div>
