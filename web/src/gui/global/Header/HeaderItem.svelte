<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let text: string | null = null
  export let icon: string | null = null
  export let type: string = 'a'

  export let _dot = false
</script>

<svelte:element this={type} class="item" class:_dot {...$$restProps} on:click>
  {#if icon}
    <SIcon name={icon} />
  {:else if $$props['data-kind'] == 'brand'}
    <img src="/icons/chivi.svg" alt="logo" />
  {/if}
  {#if text}<span class="text">{text}</span>{/if}
</svelte:element>

<style lang="scss">
  $height: 2.25rem;

  .item {
    display: inline-flex;
    align-items: center;

    position: relative;

    min-width: $height;
    user-select: none;
    text-decoration: none;

    border: none;
    outline: none;

    cursor: pointer;
    padding: 0 0.5rem;
    height: $height;

    @include fgcolor(neutral, 0);
    @include bdradi();
    @include bgcolor(primary, 7);

    :global(.__left) > &:last-child,
    &:hover {
      @include bgcolor(primary, 6);
    }

    &:disabled,
    &[disable] {
      cursor: text;
      @include fgcolor(mute);
      @include bgcolor(primary, 7);
    }

    &._dot:after {
      $size: 0.625rem;

      position: absolute;
      content: '';
      right: math.div($size * -1, 3);
      top: math.div($size * -1, 3);
      width: $size;
      height: $size;
      border-radius: $size;
      @include bgcolor(warning, 5);
    }

    :global(img),
    :global(svg) {
      width: 1.25rem !important;
      height: 1.25rem !important;
    }
  }

  .text {
    font-weight: 500;
    font-size: rem(15px);

    :global([data-show='pm']) > & {
      @include bps(display, none, $pm: inline);
    }

    :global([data-show='pl']) > & {
      @include bps(display, none, $pl: inline);
    }

    :global([data-show='ts']) > & {
      @include bps(display, none, $ts: inline);
    }

    :global([data-show='tm']) > & {
      @include bps(display, none, $tm: inline);
    }

    :global([data-show='tl']) > & {
      @include bps(display, none, $tl: inline);
    }

    :global([data-kind='brand']) > & {
      text-transform: uppercase;
      font-weight: 500;
      font-size: rem(17px);
      letter-spacing: 0.1em;
    }

    :global([data-kind='title']) > & {
      @include clamp($width: null);
      @include bps(max-width, 25vw, $tl: 12rem);
    }

    :global([data-kind='zseed']) > & {
      @include clamp($width: null);

      max-width: 25vw;
      text-transform: uppercase;
      font-size: 0.85em;
    }

    :global([data-kind='uname']) > & {
      @include clamp($width: null);
      max-width: 4.5rem;
    }

    :global(:is(svg, img)) + & {
      margin-left: 0.25rem;
    }
  }
</style>
