<script context="module">
  import { labels } from '$lib/postag.js'
</script>

<script>
  export let tag = ''
</script>

<button class="attr">
  {labels[tag] || tag || 'Chưa phân loại'}
</button>

<style lang="scss">
  .attr {
    position: absolute;
    top: 2.5rem;
    right: 0.5rem;
    line-height: 1.5rem;
    text-transform: uppercase;
    padding: 0 0.5rem;
    background: transparent;
    border-radius: 0.75rem;
    font-weight: 500;
    font-size: rem(12px);
    @include fgcolor(neutral, 6);
    @include border;

    &:hover {
      background: #fff;
    }
  }

  // .-full {
  //   @include props(display, none, $md: inline-block);
  // }

  // .-trim {
  //   @include props(display, inline-block, $md: none);
  // }
</style>
