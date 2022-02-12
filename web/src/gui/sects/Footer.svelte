<script lang="ts">
  import { scroll } from '$lib/stores'

  function observe(node) {
    const observer = new IntersectionObserver(
      ([e]) => e.target.classList.toggle('sticked', e.intersectionRatio < 1),
      { threshold: [1] }
    )

    observer.observe(node)
    return { destroy: () => observer.disconnect() }
  }
</script>

<footer class="sticky" class:_show={$scroll < 0} use:observe>
  <slot />
</footer>

<style lang="scss">
  .sticky {
    will-change: transform;
    transition: transform 100ms ease-in-out;

    position: relative;
    padding: 0.5rem var(--gutter);

    position: sticky;
    bottom: -0.1px;
    // transform: translateY(-1px);

    &:global(.sticked) {
      transform: translateY(100%);
      background: linear-gradient(color(neutral, 1, 1), color(neutral, 7, 7));

      @include tm-dark {
        background: linear-gradient(color(neutral, 7, 1), color(neutral, 8, 7));
      }
    }

    &._show:global(.sticked) {
      transform: none !important;
    }
  }
</style>
