<script>
  export let name = 'feather'
  export let spin = false
</script>

<svg class:spin viewBox="0 0 24 24">
  {#if name == 'erase'}
    <path stroke="none" d="M0 0h24v24H0z" fill="none" />
    <path
      d="M19 19h-11l-4 -4a1 1 0 0 1 0 -1.41l10 -10a1 1 0 0 1 1.41 0l5 5a1 1 0 0 1 0 1.41l-9 9" />
    <line x1="18" y1="12.3" x2="11.7" y2="6" />
  {:else}
    <use xlink:href="/icons.svg#{name}" />
  {/if}
</svg>

<style lang="scss">
  svg {
    display: inline-block;

    width: 1em;
    height: 1em;

    stroke: currentColor;
    stroke-width: 2;
    stroke-linecap: round;
    stroke-linejoin: round;
    fill: none;
  }

  // prettier-ignore
  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }

  .spin {
    animation-name: spin;
    animation-duration: 0.75s;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
</style>
