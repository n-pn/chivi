<script>
  import Vessel from '$layout/Vessel.svelte'

  export let status
  export let error

  const dev = process.env.NODE_ENV === 'development'
</script>

<style lang="scss">
  h1,
  p {
    margin: 0 auto;
  }

  h1 {
    font-size: 2.8em;
    font-weight: 700;
    margin: 0 0 0.5em 0;
  }

  p {
    margin: 1em auto;
  }

  h1 {
    @include screen-min(sm) {
      font-size: 4em;
    }
  }

  article {
    padding: 2rem;
  }
</style>

<svelte:head>
  <title>{status}</title>
</svelte:head>

<Vessel>
  <article>
    <h1>{status}</h1>

    <p>{error.message}</p>

    {#if dev && error.stack}
      <pre>{error.stack}</pre>
    {/if}
  </article>
</Vessel>
