<script context="module" lang="ts">
  import { writable } from 'svelte/store'
  import { browser } from '$app/environment'

  export const usercp = {
    ...writable(0),
    change_tab: (tab: number) => usercp.set(tab),
  }
</script>

<script lang="ts">
  import { get_user } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  import Homecp from './Config.svelte'
  import Notifs from './Notifs.svelte'

  const components = [Homecp, Notifs]

  export let actived = true
  const _user = get_user()

  $: if (actived) reload_user_data()

  const reload_user_data = async () => {
    const res = await fetch('/_db/_self')
    if (res.ok) $_user = await res.json()
  }

  const tabs = [
    { icon: 'user', btip: 'Giao diện' },
    { icon: 'bell', btip: 'Thông báo' },
  ]

  $: privi = $_user.privi || -1

  async function logout() {
    const res = await fetch('/_db/_user/logout', { method: 'DELETE' })
    if (!res.ok) return
    window.location.reload()
  }
</script>

<Slider class="usercp" bind:actived --slider-width="26rem">
  <svelte:fragment slot="header-left">
    <div class="-icon"><SIcon name="privi-{privi}" iset="icons" /></div>
    <div class="-text">
      <cv-user data-privi={privi}>{$_user.uname}</cv-user>
    </div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    {#each tabs as { icon, btip }, tab}
      {@const _hl = tab == 1 && $_user.unread_notif > 0}
      <button
        class="-btn"
        class:_active={tab == $usercp}
        class:_hl
        on:click={() => usercp.change_tab(tab)}
        data-tip={btip}
        data-tip-loc="bottom">
        <SIcon name={icon} />
        {#if _hl}{$_user.unread_notif}{/if}
      </button>
    {/each}
    <button
      class="-btn"
      on:click={logout}
      data-tip="Đăng xuất"
      data-tip-loc="bottom">
      <SIcon name="logout" />
    </button>
  </svelte:fragment>

  <section class="body">
    {#if actived && browser}
      <svelte:component this={components[$usercp]} {_user} />
    {/if}
  </section>
</Slider>

<style lang="scss">
  // .-btn._dot:after {
  //   $size: 0.625rem;
  //   position: absolute;

  //   content: '';
  //   right: math.div($size * -1, 3);
  //   top: math.div($size * -1, 3);
  //   width: $size;
  //   height: $size;
  //   border-radius: $size;
  //   @include bgcolor(warning, 5);
  // }

  .-btn._hl {
    @include fgcolor(warning, 5);
  }

  .-btn._active {
    // @include bgcolor(primary, 1, 5);
    @include fgcolor(primary, 5);
  }

  .body {
    padding: 0.5rem 0.75rem;
  }
</style>
