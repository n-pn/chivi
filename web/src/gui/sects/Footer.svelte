<script lang="ts">
  import { scroll } from '$lib/stores'

  function observe(node: Element) {
    const observer = new IntersectionObserver(
      ([e]) => e.target.classList.toggle('sticky', e.intersectionRatio < 1),
      { threshold: [1] }
    )

    observer.observe(node)
    return { destroy: () => observer.disconnect() }
  }
</script>

<footer class:show={$scroll <= 0} use:observe><slot /></footer>

<style lang="scss">
  footer {
    @include flex-cx;
    position: sticky;
    padding: 0.5rem 0;

    will-change: transform;
    transition: transform 100ms ease-in-out;

    // bottom: 0;
    bottom: -0.1px;

    &:global(.sticky) {
      background-color: color(neutral, 5, 5);
      transform: translateY(100%);
      // @include bdradi(0.5rem, $loc: top);

      --bg-to: #{color(neutral, 7, 7)};
      --bg-from: #{color(neutral, 1, 1)};
      background: linear-gradient(var(--bg-from), var(--bg-to));

      @include tm-dark {
        --bg-from: #{color(neutral, 7, 1)};
        --bg-to: #{color(neutral, 8, 7)};
      }

      &.show {
        // transform: translateY(100%);
        transform: none;
      }
    }
  }
</style>
