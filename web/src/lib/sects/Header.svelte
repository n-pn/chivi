<script>
  import { session } from '$app/stores'
  import { scroll, toleft } from '$lib/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Signin from '$parts/Signin.svelte'
  import Appnav from '$parts/Appnav.svelte'
  import Usercp from '$parts/Usercp.svelte'

  let active_usercp = false
  let active_appnav = false
</script>

<header class="app-header" class:_shift={$toleft} class:_clear={$scroll > 0}>
  <nav class="vessel -wrap">
    <div class="-left">
      <button
        class="header-item _brand"
        on:click={() => (active_appnav = true)}>
        <img src="/icons/chivi.svg" alt="logo" />
        <span class="header-text _show-lg">Chivi</span>
      </button>

      <slot name="left" />
    </div>

    <div class="-right">
      <slot name="right" />

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $session.privi >= 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>
  </nav>
</header>

<Appnav bind:actived={active_appnav} />

{#if $session.uname == 'Khách'}
  <Signin bind:actived={active_usercp} />
{:else}
  <Usercp bind:actived={active_usercp} />
{/if}
