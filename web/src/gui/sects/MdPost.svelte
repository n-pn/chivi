<script lang="ts">
  export let title = 'Untitled'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<article class="article md-post">
  <h1>{title}</h1>
  <slot />
</article>
