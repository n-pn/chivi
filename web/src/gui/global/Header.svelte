<script lang="ts">
  import { page } from '$app/stores'
  import { scroll, popups, get_user } from '$lib/stores'

  import { default_meta } from '$utils/header_util'
  import Item from './Header/HeaderItem.svelte'
  import Appnav from './Modals/Appnav.svelte'
  import Usercp from '../shared/usercp/Usercp.svelte'
  import Dboard from './Modals/Dboard.svelte'

  const _user = get_user()

  $: meta = $page.data._meta || default_meta

  $: title = $page.data._title || 'Trang chủ'
  $: image = $page.data._image || '/imgs/avatar.png'
  $: mdesc = $page.data._mdesc || ''

  $: thread = $page.data._board || ''
</script>

<svelte:head>
  <title>{title} - Chivi</title>
  <meta name="description" content={mdesc} />

  {#if meta.url}<meta property="og:url" content={meta.url} />{/if}

  <meta property="og:title" content={title} />
  <meta property="og:description" content={mdesc} />
  <meta property="og:image" content="https://cdn.chivi.app{image}" />
</svelte:head>

<header class="app-header" class:clear={$scroll > 0}>
  <nav class="app-vessel">
    <div class="-left __left">
      <button
        type="button"
        class="appbar-item _brand"
        on:click={() => popups.show('appnav')}>
        <img src="/icons/chivi.svg" alt="logo" />
        <span class="appbar-text u-show-ts">Chivi</span>
      </button>
      {#each meta.left_nav || [] as data}<Item {...data} />{/each}
    </div>

    <div class="-right">
      {#each meta.right_nav || [] as data}<Item {...data} />{/each}

      {#if thread}
        <Item
          type="button"
          icon="message-circle"
          data-kbd="f"
          on:click={() => popups.show('dboard')} />
      {/if}

      {#if $_user.uname != 'Khách'}
        <Item
          type="button"
          text={$_user.uname}
          icon="privi-{$_user.privi}"
          iset="icons"
          _dot={$_user.unread_notif > 0}
          opts={{ show: 'pl', kind: 'uname' }}
          data-kbd="u"
          on:click={() => popups.show('usercp')} />
      {:else}
        <Item
          type="a"
          href="/_auth/login"
          text="Đăng nhập"
          icon="login"
          opts={{ show: 'pl', kind: 'uname' }}
          data-kbd="u" />
      {/if}
    </div>
  </nav>
</header>

{#if $popups.appnav}<Appnav bind:actived={$popups.appnav} />{/if}
{#if $popups.dboard}<Dboard {thread} bind:actived={$popups.dboard} />{/if}
{#if $popups.usercp}<Usercp bind:actived={$popups.usercp} />{/if}

<style lang="scss">
  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $header-gutter: math.div($header-height - $header-inner-height, 2);

  .app-header {
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
