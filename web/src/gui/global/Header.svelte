<script lang="ts">
  import { page } from '$app/stores'
  import { scroll, popups } from '$lib/stores'

  import Item from './Header/HeaderItem.svelte'

  $: left_nav = $page.data._head_left || []
  $: right_nav = $page.data._head_right || []
</script>

<header class="app-header" class:clear={$scroll > 0}>
  <nav class="app-vessel">
    <div class="-left">
      <Item
        type="button"
        icon="menu-2"
        on:click={() => popups.show('appnav')} />

      {#if left_nav.length < 2}
        <Item type="a" href="/" data-kind="brand" show="tl" text="Chivi">
          <img src="/icons/chivi.svg" alt="logo" slot="icon" />
        </Item>
      {/if}

      {#each left_nav as opts, idx}
        {@const active = idx == left_nav.length - 1 || null}
        <Item type="a" {...opts} {active} />
      {/each}
    </div>

    <div class="-right">
      {#each right_nav as opts}
        {@const type = opts.href ? 'a' : 'button'}
        <Item {type} {...opts} />
      {/each}

      {#if $page.data._head_config}
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

      <Item
        type="button"
        text={$page.data._user?.uname || 'Khách'}
        icon="user"
        data-kbd="u"
        data-show="tl"
        data-kind="uname"
        on:click={() => popups.show('usercp')} />
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
