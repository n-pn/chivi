<script lang="ts">
  export let title = 'Untitled'
  import { Vessel } from '$gui'

  $: topbar = {
    lefts: [[title, 'news', { kind: 'title' }]],
    config: true,
  }
</script>

<svelte:head>
  <title>{title} - Chivi</title>
</svelte:head>

<Vessel {topbar}>
  <section>
    <article class="md-post">
      <h1>{title}</h1>
      <slot />
    </article>
  </section>
</Vessel>
