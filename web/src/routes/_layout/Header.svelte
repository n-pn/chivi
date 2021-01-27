<script context="module">
  import { u_dname, u_power, l_scroll } from '$src/stores'
  import SIcon from '$blocks/SIcon'

  import Signin from '$widget/Signin'
  import Usercp from '$widget/Usercp'
</script>

<script>
  let active_usercp = false
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

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $u_power > 0}{$u_dname} [{$u_power}]{:else}Khách{/if}
        </span>
      </button>
    </div>
  </nav>
</header>

{#if $u_dname == 'Khách'}
  <Signin bind:actived={active_usercp} />
{:else}
  <Usercp bind:actived={active_usercp} />
{/if}
