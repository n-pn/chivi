<script>
  export let active = true
  export let scale = false
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  viewBox="0 0 24 24"
  width="24"
  height="24"
  class="star"
  class:active
  class:scale
  fill="currentColor"
  ><path
    fill-rule="evenodd"
    d="M12.672.668a.75.75 0 00-1.345 0L8.27 6.865l-6.838.994a.75.75 0 00-.416 1.279l4.948 4.823-1.168 6.811a.75.75 0 001.088.791L12 18.347l6.117 3.216a.75.75 0 001.088-.79l-1.168-6.812 4.948-4.823a.75.75 0 00-.416-1.28l-6.838-.993L12.672.668z" /></svg>

<style lang="scss">
  .star {
    color: var(--bd-soft);

    &.active {
      color: rgb(247, 186, 42);
    }

    // &.scale {
    //   transform: scale(1.2);
    // }
  }
</style>
