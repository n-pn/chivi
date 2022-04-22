<script lang="ts">
  import { topbar } from '$lib/stores'

  export let title = 'Untitled'

  $: $topbar = {
    left: [[title, 'news', { kind: 'title' }]],
    config: true,
  }
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<section>
  <article class="md-post">
    <h1>{title}</h1>
    <slot />
  </article>
</section>
