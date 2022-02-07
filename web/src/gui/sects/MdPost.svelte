<script>
  export let title
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<article class="md-post">
  <h1>{title}</h1>
  <slot />
</article>
