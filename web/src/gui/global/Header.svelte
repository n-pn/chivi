<script lang="ts">
  import { page } from '$app/stores'
  import { scroll, popups } from '$lib/stores'

  import { gen_meta } from './header_util'
  import Item from './Header/HeaderItem.svelte'

  $: meta = $page.data._meta || gen_meta($page.route?.id || '/', $page.data)
  $: user = $page.data._user

  $: image = meta.image || '/imgs/avatar.png'
</script>

<svelte:head>
  <title>{meta.title || ''} - Chivi</title>
  <meta name="description" content={meta.desc} />

  {#if meta.url}<meta property="og:url" content={meta.url} />{/if}

  <meta property="og:title" content={meta.title} />
  <meta property="og:description" content={meta.desc} />
  <meta property="og:image" content="https://chivi.app{image}" />
</svelte:head>

<header class="app-header" class:clear={$scroll > 0}>
  <nav class="app-vessel">
    <div class="-left __left">
      <Item
        type="button"
        icon="menu-2"
        on:click={() => popups.show('appnav')} />
      {#each meta.left_nav || [] as opts}<Item {...opts} />{/each}
    </div>

    <div class="-right">
      {#each meta.right_nav || [] as opts}<Item {...opts} />{/each}

      {#if meta.show_config}
        <Item
          type="button"
          text="Cài đặt"
          icon="adjustments-alt"
          data-kbd="o"
          data-show="tl"
          on:click={() => popups.show('config')} />
      {/if}

      <Item
        type="button"
        text="Thảo luận"
        icon="messages"
        data-kbd="f"
        data-show="tl"
        on:click={() => popups.show('dboard')} />

      {#if user.uname != 'Khách'}
        <Item
          type="button"
          text={user.uname}
          icon="user"
          _dot={user.unread_notif > 0}
          data-kbd="u"
          data-show="tl"
          data-kind="uname"
          on:click={() => popups.show('usercp')} />
      {:else}
        <Item
          type="a"
          href="/_auth/login"
          text="Đăng nhập"
          icon="login"
          data-kbd="u"
          data-show="tl"
          data-kind="uname" />
      {/if}
    </div>
  </nav>
</header>

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
