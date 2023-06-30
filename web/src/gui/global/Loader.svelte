<script lang="ts">
  import { onDestroy, onMount } from 'svelte'
  import { tweened } from 'svelte/motion'
  import { cubicOut } from 'svelte/easing'
  import { fade } from 'svelte/transition'

  import { navigating } from '$app/stores'

  const interval = 1500
  const progress = tweened(0, { duration: interval, easing: cubicOut })

  const unsubscribe = navigating.subscribe((state) => {
    if (!state) progress.set(100, { duration: 100 })
  })

  let ticking: number // fake progress

  function fake_progress() {
    progress.update((x) => x + Math.floor((100 - x) / 2))
    ticking = window.setTimeout(fake_progress, interval)
  }

  onMount(() => {
    progress.set(85)
    ticking = window.setTimeout(fake_progress, interval)
  })

  onDestroy(() => {
    clearTimeout(ticking)
    unsubscribe()
  })
</script>

<progress-bar out:fade|global={{ delay: 50 }}>
  <progress-value style="--width: {$progress}%" />
</progress-bar>

<style lang="scss">
  progress-bar {
    position: fixed;
    z-index: 99999;
    top: 0;
    left: 0;

    display: block;
    width: 100%;
  }

  progress-value {
    display: block;
    height: 0.125rem;
    width: var(--width, 0%);
    @include bgcolor(primary, 4);
  }
</style>
