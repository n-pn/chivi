<script>
  export let name = 'feather'
  export let spin = false
</script>

<svg class:spin>
  <use xlink:href="/icons.svg#{name}" />
</svg>

<style lang="scss">
  svg {
    display: inline-block;
    width: 1em;
    height: 1em;

    stroke: currentColor;
    stroke-width: 1.5;
    stroke-linecap: round;
    stroke-linejoin: round;
    fill: none;
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }

  .spin {
    animation-name: spin;
    animation-duration: 0.5s;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
  }
</style>
