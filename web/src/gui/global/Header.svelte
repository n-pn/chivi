<script lang="ts">
  import { page } from '$app/stores'
  import { scroll, popups, get_user } from '$lib/stores'

  import Item from './Header/HeaderItem.svelte'
  import Navi from './Header/HeaderNavi.svelte'

  import Usercp from '../shared/usercp/Usercp.svelte'
  import Config from '../shared/reader/Config.svelte'
  import Navbar from '$gui/global/Navbar.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  const _user = get_user()

  $: ({ _meta, _alts = [] } = $page.data)
  $: ({ _prev, _curr } = init_navi($page.data))
  $: title = _meta?.title || _curr?.text || 'Trang chủ'

  const init_navi = ({ _navs = [], _prev, _curr }: App.PageData) => {
    const size = _navs.length

    if (size > 1) _prev = { ..._navs[size - 2], ...(_prev || {}) }
    if (size > 0) _curr = { ..._navs[size - 1], ...(_curr || {}) }

    return { _prev, _curr }
  }
</script>

<svelte:head>
  <title>{title} - Chivi</title>
  <meta name="description" content={_meta?.mdesc || ''} />

  {#if _meta?.ogurl}<meta property="og:url" content={_meta.ogurl} />{/if}

  <meta property="og:title" content={title} />
  <meta property="og:description" content={_meta?.mdesc || ''} />
  <meta property="og:image" content={_meta?.image} />
</svelte:head>

<header class="app-header">
  <nav class="app-vessel">
    <div class="-left">
      <button class="appbar-item" on:click={() => popups.show('navbar')}>
        <SIcon name="menu-2" />
      </button>
      <a href="/" class="appbar-item _brand">
        <img src="/icons/chivi.svg" alt="logo" />
        <span class="appbar-text" class:u-show-tm={!!_prev}>Chivi</span>
      </a>

      {#if _prev}<Navi {..._prev} />{/if}
      {#if _curr}<Navi {..._curr} />{/if}

      <!-- {#each meta.left_nav || [] as data}<Item {...data} />{/each} -->
    </div>

    <div class="-right">
      {#each _alts as item}
        <Navi {...item} />
      {/each}

      {#if $page.data._show_conf}
        <Item
          type="button"
          icon="adjustments"
          text="Cài đặt"
          show="pl"
          on:click={() => popups.show('config')} />
      {/if}

      {#if $_user.uname != 'Khách'}
        <Item
          type="button"
          text={$_user.uname}
          icon="privi-{$_user.privi}"
          iset="icons"
          kind="uname"
          show="pl"
          _dot={$_user.unread_notif > 0}
          on:click={() => popups.show('usercp')} />
      {:else}
        <Item
          type="a"
          href="/_u/login"
          text="Đăng nhập"
          icon="login"
          kind="uname"
          show="pl"
          data-kbd="u" />
      {/if}
    </div>
  </nav>
</header>

{#if $popups.navbar}<Navbar bind:actived={$popups.navbar} />{/if}
{#if $popups.usercp}<Usercp bind:actived={$popups.usercp} />{/if}
{#if $popups.config}<Config bind:actived={$popups.config} />{/if}

<style lang="scss">
  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $header-gutter: math.div($header-height - $header-inner-height, 2);

  .app-header {
    // transition: transform 100ms ease-in-out;
    // will-change: transform;

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

    // &.clear {
    //   // top: -$header-height;
    //   transform: translateY(-$header-height);
    // }
  }

  .app-vessel {
    display: flex;
    position: relative;

    padding-top: 0;
    padding-bottom: 0;
  }

  .-left,
  .-right {
    @include flex($gap: var(--gutter-pm));
    margin: 0;
  }

  .-left {
    flex-grow: 1;
  }

  .-right {
    padding-left: $header-gutter;
  }
</style>
