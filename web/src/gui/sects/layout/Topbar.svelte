<script lang="ts">
  import { session } from '$app/stores'
  import { scroll, toleft, popups } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Config from '$gui/sects/reader/Config.svelte'
  import BarItem from '$gui/parts/topbar/BarItem.svelte'

  export let config = false
  $: uname = $session.privi < 0 ? 'Khách' : $session.uname
</script>

<nav class:shift={$toleft} class:clear={$scroll > 0}>
  <div class="vessel -wrap">
    <div class="-left">
      <BarItem this="button" on:click={() => popups.show('appnav')}>
        <SIcon name="menu-2" slot="icon" />
      </BarItem>

      <BarItem this="a" href="/" kind="brand" show="tl" text="Chivi">
        <img src="/icons/chivi.svg" alt="logo" slot="icon" />
      </BarItem>

      <slot name="left" />
    </div>

    <div class="-right">
      <slot name="right" />

      {#if config}
        <BarItem
          this="button"
          text="Cài đặt"
          show="tl"
          data-kbd="o"
          on:click={() => popups.show('config')}>
          <SIcon name="adjustments-alt" slot="icon" />
        </BarItem>
      {/if}

      <BarItem
        this="button"
        text="Thảo luận"
        show="tl"
        data-kbd="f"
        on:click={() => popups.show('dboard')}>
        <SIcon name="messages" slot="icon" />
      </BarItem>

      <BarItem
        this="button"
        text={uname}
        kind="uname"
        show="tl"
        data-kbd="u"
        on:click={() => popups.show('usercp')}>
        <SIcon name="user" slot="icon" />
      </BarItem>

      {#if $popups.config}<Config />{/if}
    </div>
  </div>
</nav>

<style lang="scss">
  $header-height: 3rem;
  $header-inner-height: 2.25rem;
  $header-gutter: math.div($header-height - $header-inner-height, 2);

  nav {
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
