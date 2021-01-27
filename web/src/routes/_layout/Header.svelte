<script context="module">
  import { u_dname, u_power, l_scroll } from '$src/stores'
  import SIcon from '$blocks/SIcon.svelte'
</script>

<script>
  async function logout() {
    $u_dname = 'Khách'
    $u_power = 0

    localStorage.removeItem('_self')
    await fetch('api/logout')
  }
</script>

<header class="app-header" class:_clear={$l_scroll > 0}>
  <nav class="center -wrap">
    <div class="-left">
      <a href="/" class="header-item _brand">
        <img src="/chivi-logo.svg" alt="logo" />
        <span class="header-text _show-md">Chivi</span>
      </a>

      <slot name="header-left" />
    </div>

    <div class="-right">
      <slot name="header-right" />

      <span class="header-item _menu">
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $u_power > 0}{$u_dname} [{$u_power}]{:else}Khách{/if}
        </span>

        <div class="header-menu">
          {#if $u_power < 1}
            <a href="/auth/login" class="-item">
              <SIcon name="log-in" />
              <span>Đăng nhập</span>
            </a>
            <a href="/auth/signup" class="-item">
              <SIcon name="user-plus" />
              <span>Đăng ký</span>
            </a>
          {:else}
            <a href="/@{$u_dname}" class="-item">
              <SIcon name="layers" />
              <span>Tủ truyện</span>
            </a>
            <a
              href="/auth/logout"
              class="-item"
              on:click|preventDefault={logout}>
              <SIcon name="log-out" />
              <span>Đăng xuất</span>
            </a>
          {/if}
        </div>
      </span>
    </div>
  </nav>
</header>
