<script>
  export let title
  import Vessel from './Vessel.svelte'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<Vessel>
  <article class="md-post">
    <h1>{title}</h1>
    <slot />
  </article>
</Vessel>
