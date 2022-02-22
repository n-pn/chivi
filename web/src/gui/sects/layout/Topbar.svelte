<script context="module" lang="ts">
  import { session } from '$app/stores'
  import { appbar, scroll, toleft, usercp, config_ctrl } from '$lib/stores'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Signin from '$gui/parts/Signin.svelte'
  import Appnav from '$gui/parts/Appnav.svelte'
  import Usercp from '$gui/parts/Usercp.svelte'
  import Config from '$gui/sects/reader/Config.svelte'

  let active_appnav = false
</script>

<app-bar class:shift={$toleft} class:clear={$scroll > 0}>
  <nav class="vessel -wrap">
    <div class="-left">
      <button class="appbar-item" on:click={() => (active_appnav = true)}>
        <SIcon name="menu-2" />
      </button>

      <a href="/" class="appbar-item _brand _show-sm">
        <img src="/icons/chivi.svg" alt="logo" />
        <span class="appbar-text _show-lg">Chivi</span>
      </a>

      {#if $appbar.left}
        {#each $appbar.left as [label, icon, href, _item = '', _text = ''], idx}
          {#if href}
            <a
              class="appbar-item {_item}"
              class:_active={idx == $appbar.left.length - 1}
              {href}>
              {#if icon}<SIcon name={icon} />{/if}
              <span class="appbar-text {_text}">{label}</span>
            </a>
          {:else}
            <span
              class="appbar-item {_item}"
              class:_active={idx == $appbar.left.length - 1}>
              {#if icon}<SIcon name={icon} />{/if}
              <span class="appbar-text {_text}">{label}</span>
            </span>
          {/if}
        {/each}
      {:else}
        <form class="appbar-field" action="/books/query" method="get">
          <input
            type="search"
            name="q"
            placeholder="Tìm truyện"
            value={$appbar.query || ''} />
          <SIcon name="search" />
        </form>
      {/if}
    </div>

    <div class="-right">
      {#if $appbar.right}
        {#each $appbar.right as [label, icon, meta, opts = { }]}
          {@const _item = opts._item || ''}
          {@const _text = opts._text || ''}

          {#if typeof meta == 'function'}
            <button
              class="appbar-item {_item}"
              data-kbd={opts.kbd}
              on:click={meta}>
              {#if icon}<SIcon name={icon} />{/if}
              <span class="appbar-text {_text}">{label}</span>
            </button>
          {:else}
            <a
              class="appbar-item {_item}"
              data-kbd={opts.kbd}
              href={meta || '.'}>
              {#if icon}<SIcon name={icon} />{/if}
              <span class="appbar-text {_text}">{label}</span>
            </a>
          {/if}
        {/each}
      {/if}

      {#if $appbar.cvmtl}
        <button class="appbar-item" data-kbd="o" on:click={config_ctrl.show}>
          <SIcon name="adjustments-alt" />
          <span class="appbar-text _show-md">Cài đặt </span>
        </button>
      {/if}

      <button class="appbar-item" on:click={() => usercp.show()}>
        <SIcon name="user" />
        <span class="appbar-text _show-md">
          {#if $session.privi >= 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>

    {#if $config_ctrl.actived}<Config />{/if}
  </nav>
</app-bar>

{#if active_appnav}
  <Appnav bind:actived={active_appnav} />
{/if}

{#if $usercp.actived}
  {#if $session.uname == 'Khách'}
    <Signin bind:actived={$usercp.actived} />
  {:else}
    <Usercp />
  {/if}
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
