<script>
  import Vessel from '$layout/Vessel'

  export let status
  export let error

  const dev = process.env.NODE_ENV === 'development'
</script>

<svelte:head>
  <title>{status} - Chivi</title>
</svelte:head>

<Vessel>
  <section class="wrapper">
    <article class="content">
      <h1>{status}</h1>
      <p>{error.message}</p>

      {#if dev && error.stack}
        <pre>{error.stack}</pre>
      {/if}
    </article>
  </section>
</Vessel>

<style lang="scss">
  .wrapper {
    min-height: 80vh;
    @include flex($center: both);
  }

  .content {
    padding: 2rem;
    // width: 20rem;
    text-align: center;
    max-width: 100%;
  }

  h1 {
    font-size: 4rem;
    font-weight: 300;
    margin-bottom: 0.5rem;
    @include fgcolor(neutral, 7);
    // margin: 0 0 0.5em 0;

    @include screen-min(sm) {
      font-size: 4.5rem;
    }
  }

  p {
    margin-top: 1.5rem;
    font-style: italic;
    @include fgcolor(neutral, 8);
  }
</style>
