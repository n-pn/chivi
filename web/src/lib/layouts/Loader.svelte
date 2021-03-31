<script>
  export let active = false
</script>

<div class="holder" class:_active={active}>
  <svg class="loader" viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">
    <circle
      class="path"
      fill="none"
      stroke-width="6"
      stroke-linecap="round"
      cx="33"
      cy="33"
      r="30" />
  </svg>
</div>

<style lang="scss">
  .holder {
    position: fixed;
    z-index: 99999;
    bottom: 0;
    right: 0;

    visibility: hidden;

    &._active {
      visibility: visible;
    }
  }

  // Here is where the magic happens

  $offset: 187;
  $duration: 1.4s;

  .loader {
    margin: 1rem;
    width: 2rem;
    height: 2rem;
    animation: rotator $duration linear infinite;
  }

  .path {
    stroke-dasharray: $offset;
    stroke-dashoffset: 0;
    transform-origin: center;
    animation: dash $duration ease-in-out infinite,
      colors ($duration * 4) ease-in-out infinite;
  }

  @keyframes rotator {
    0% {
      transform: rotate(0deg);
    }
    100% {
      transform: rotate(270deg);
    }
  }

  @keyframes colors {
    0% {
      stroke: #4285f4;
    }
    25% {
      stroke: #de3e35;
    }
    50% {
      stroke: #f7c223;
    }
    75% {
      stroke: #1b9a59;
    }
    100% {
      stroke: #4285f4;
    }
  }

  @keyframes dash {
    0% {
      stroke-dashoffset: $offset;
    }
    50% {
      stroke-dashoffset: $offset/4;
      transform: rotate(135deg);
    }
    100% {
      stroke-dashoffset: $offset;
      transform: rotate(450deg);
    }
  }
</style>
