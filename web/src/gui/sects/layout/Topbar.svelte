<script lang="ts">
  import { session } from '$app/stores'
  import { scroll, popups } from '$lib/stores'

  import BarItem from '../topbar/BarItem.svelte'
  import Config from '$gui/sects/reader/Config.svelte'

  type Item = [string, string | undefined, Record<string, any> | undefined]

  export let lefts: Item[] = []
  export let rights: Item[] = []
  export let config = false

  $: uname = $session.privi < 0 ? 'Khách' : $session.uname
</script>

<nav class:clear={$scroll > 0}>
  <div class="vessel -wrap">
    <div class="-left">
      <BarItem
        this="button"
        on:click={() => popups.show('appnav')}
        icon="menu-2" />

      <BarItem this="a" href="/" kind="brand" show="tl" text="Chivi">
        <img src="/icons/chivi.svg" alt="logo" slot="icon" />
      </BarItem>

      {#each lefts as [text, icon, opts], idx}
        {@const active = idx == lefts.length - 1 || null}
        <BarItem this="a" {text} {icon} {...opts} {active} />
      {/each}
    </div>

    <div class="-right">
      {#each rights as [text, icon, opts = { }]}
        {@const type = opts.href ? 'a' : 'button'}
        <BarItem this={type} {text} {icon} {...opts} />
      {/each}

      {#if config}
        <BarItem
          this="button"
          text="Cài đặt"
          show="tl"
          icon="adjustments-alt"
          data-kbd="o"
          on:click={() => popups.show('config')} />
      {/if}

      <BarItem
        this="button"
        text="Thảo luận"
        show="tl"
        icon="messages"
        data-kbd="f"
        on:click={() => popups.show('dboard')} />

      <BarItem
        this="button"
        text={uname}
        kind="uname"
        show="tl"
        data-kbd="u"
        icon="user"
        on:click={() => popups.show('usercp')} />
    </div>

    {#if $popups.config}<Config />{/if}
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
