<script lang="ts">
  export let html: string

  export let view_all = false

  let elm: HTMLElement

  $: clamped = !view_all && is_clamped(elm)

  function is_clamped(elm: HTMLElement) {
    if (!elm) return true
    return elm.scrollHeight > elm.clientHeight
  }
</script>

<div class:_full={view_all} class:_trim={clamped || !view_all} bind:this={elm}>
  {@html html}
</div>

<style lang="scss">
  div:not(._full) {
    display: -webkit-box;
    -webkit-line-clamp: var(--line, 10);
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: '……';
  }

  ._trim {
    --bg-hide: #{color(neutral, 7, 1)};

    background: linear-gradient(
      to top,
      color(--bg-hide) 0.125rem,
      transparent 0.5rem
    );

    @include tm-dark {
      --bg-hide: #{color(neutral, 5, 1)};
    }
  }
</style>
