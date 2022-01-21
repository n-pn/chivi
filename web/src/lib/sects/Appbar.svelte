<script context="module">
  import { writable } from 'svelte/store'
  import { browser } from '$app/env'
  import { session } from '$app/stores'
  import { scroll, toleft } from '$lib/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import Signin from '$parts/Signin.svelte'
  import Appnav from '$parts/Appnav.svelte'
  import Usercp from '$parts/Usercp.svelte'

  import Config from './Appbar/Config.svelte'

  export const data = writable({})
</script>

<script>
  let active_usercp = false
  let active_appnav = false
  let active_config = false
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

      {#if $data.left}
        {#each $data.left as [label, icon, href, _item = '', _text = ''], idx}
          {#if href}
            <a
              class="appbar-item {_item}"
              class:_active={idx == $data.left.length - 1}
              {href}>
              {#if icon}<SIcon name={icon} />{/if}
              <span class="appbar-text {_text}">{label}</span>
            </a>
          {:else}
            <span
              class="appbar-item {_item}"
              class:_active={idx == $data.left.length - 1}>
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
            value={$data.query || ''} />
          <SIcon name="search" />
        </form>
      {/if}
    </div>

    <div class="-right">
      {#if $data.right}
        {#each $data.right as [label, icon, meta, opts = { }]}
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

      {#if $data.page == 'index'}
        <a href="/qtran" class="appbar-item">
          <SIcon name="bolt" />
          <span class="appbar-text _show-lg">Dịch nhanh</span>
        </a>

        <a href="/crits" class="appbar-item">
          <SIcon name="stars" />
          <span class="appbar-text _show-lg">Đánh giá</span>
        </a>
      {/if}

      {#if $data.cvmtl}
        <button
          class="appbar-item"
          data-kbd="o"
          on:click={() => (active_config = true)}>
          <SIcon name="adjustments-alt" />
          <span class="appbar-text _show-md">Cài đặt </span>
        </button>
      {/if}

      <button class="appbar-item" on:click={() => (active_usercp = true)}>
        <SIcon name="user" />
        <span class="appbar-text _show-md">
          {#if $session.privi >= 0}{$session.uname} [{$session.privi}]{:else}Khách{/if}
        </span>
      </button>
    </div>

    {#if active_config}
      <Config bind:actived={active_config} />
    {/if}
  </nav>
</app-bar>

{#if browser}
  <Appnav bind:actived={active_appnav} />

  {#if $session.uname == 'Khách'}
    <Signin bind:actived={active_usercp} />
  {:else}
    <Usercp bind:actived={active_usercp} />
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
