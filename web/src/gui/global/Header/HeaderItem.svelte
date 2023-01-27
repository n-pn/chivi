<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let text: string = ''
  export let icon: string = ''
  export let type: string = 'span'
</script>

<svelte:element this={type} class="topbar-item" {...$$restProps} on:click>
  {#if icon}
    <SIcon name={icon} />
  {:else if $$props['data-kind'] == 'brand'}
    <img src="/icons/chivi.svg" alt="logo" />
  {/if}
  {#if text}<span class="-text">{text}</span>{/if}
</svelte:element>

<style lang="scss">
  $height: 2.25rem;

  .topbar-item {
    display: inline-flex;
    align-items: center;

    position: relative;

    min-width: $height;
    user-select: none;

    cursor: pointer;
    padding: 0 0.5rem;
    height: $height;
    // line-height: $height;

    @include fgcolor(neutral, 0);
    @include bdradi();
    @include bgcolor(primary, 7);

    :global(.__left) > &:last-child,
    &:hover {
      @include bgcolor(primary, 6);
    }

    &[data-kind='brand'] {
      @include bps(display, none, $ts: inline-flex);
    }

    &:disabled,
    &[disable] {
      cursor: text;
      @include fgcolor(mute);
      @include bgcolor(primary, 7);
    }

    :global(img),
    :global(svg) {
      width: 1.25rem !important;
      height: 1.25rem !important;
    }
  }

  :is(a).topbar-item {
    text-decoration: none;
  }

  :is(button).topbar-item {
    border: none;
    outline: none;
  }

  .-text {
    font-weight: 500;
    font-size: rem(15px);

    [data-show='pl'] > & {
      @include bps(display, none, $pl: inline);
    }

    [data-show='ts'] > & {
      @include bps(display, none, $ts: inline);
    }

    [data-show='tm'] > & {
      @include bps(display, none, $tm: inline);
    }

    [data-show='tl'] > & {
      @include bps(display, none, $tl: inline);
    }

    [data-kind='brand'] > & {
      text-transform: uppercase;
      font-weight: 500;
      font-size: rem(17px);
      letter-spacing: 0.1em;
    }

    [data-kind='title'] > & {
      @include clamp($width: null);
      @include bps(max-width, 25vw, $tl: 12rem);
    }

    [data-kind='zseed'] > & {
      @include clamp($width: null);

      max-width: 25vw;
      text-transform: uppercase;
      font-size: 0.85em;
    }

    [data-kind='uname'] > & {
      @include clamp($width: null);
      max-width: 4.5rem;
    }

    :global(:is(svg, img)) + & {
      margin-left: 0.25rem;
    }
  }
</style>
