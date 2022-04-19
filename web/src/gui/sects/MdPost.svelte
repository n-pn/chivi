<script lang="ts">
  export let title = 'Untitled'
  import { MainApp } from '$gui'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<MainApp>
  <section>
    <article class="md-post">
      <h1>{title}</h1>
      <slot />
    </article>
  </section>
</MainApp>
