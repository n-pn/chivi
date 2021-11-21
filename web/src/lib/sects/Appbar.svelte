<script context="module">
  import { session } from '$app/stores'
  import { scroll, toleft } from '$lib/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Signin from '$parts/Signin.svelte'
  import Appnav from '$parts/Appnav.svelte'
  import Usercp from '$parts/Usercp.svelte'

  import Config from './Appbar/Config.svelte'
</script>

<script>
  export let ptype = ''

  let active_usercp = false
  let active_appnav = false
  let active_config = false
</script>

<app-bar class:shift={$toleft} class:clear={$scroll > 0}>
  <nav class="vessel -wrap">
    <div class="-left">
      <button class="header-item" on:click={() => (active_appnav = true)}>
        <SIcon name="menu-2" />
      </button>

      <a href="/" class="header-item _brand _show-sm">
        <img src="/icons/chivi.svg" alt="logo" />
        <span class="header-text _show-lg">Chivi</span>
      </a>

      <slot name="left" />
    </div>

    <div class="-right">
      <slot name="right" />

      {#if ptype == 'cvmtl'}
        <button
          class="header-item"
          data-kbd="c"
          on:click={() => (active_config = true)}>
          <SIcon name="settings" />
          <span class="header-text _show-md">Cài đặt </span>
        </button>
      {/if}

      <button class="header-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="header-text _show-md">
          {#if $session.privi >= 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>

    {#if active_config}
      <Config bind:actived={active_config} />
    {/if}
  </nav>
</app-bar>

<Appnav bind:actived={active_appnav} />

{#if $session.uname == 'Khách'}
  <Signin bind:actived={active_usercp} />
{:else}
  <Usercp bind:actived={active_usercp} />
{/if}

<style lang="scss">
  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $header-gutter: math.div($header-height - $header-inner-height, 2);

  app-bar {
    transition: transform 100ms ease-in-out;
    will-change: transform;

    position: sticky;
    display: block;
    z-index: 50;

    top: 0;
    left: 0;

    width: 100%;
    height: $header-height;
    padding: $header-gutter 0;

    color: #fff;
    @include bgcolor(primary, 8);

    @include shadow(2);

    &.clear {
      // top: -$header-height;
      transform: translateY(-$header-height);
    }

    .-wrap {
      display: flex;
      position: relative;
    }

    .-left,
    .-right {
      @include flex($gap: var(--gutter-pm));
    }

    .-left {
      flex-grow: 1;
    }

    .-right {
      padding-left: $header-gutter;
    }
  }
</style>
