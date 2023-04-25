<script lang="ts">
  import { page } from '$app/stores'
</script>

<svelte:head>
  <title>{$page.status} - Chivi</title>
</svelte:head>

<section class="wrapper">
  <article class="content">
    <h1>{$page.status}</h1>

    {#if $page.status == 404}
      <p>{$page.error.message || 'Đường dẫn không tồn tại!'}</p>
    {:else}
      <p>{$page.error.message}</p>
    {/if}
  </article>
</section>

<style lang="scss">
  .wrapper {
    min-height: 80vh;
    @include flex-ca;
  }

  .content {
    padding: 2rem;
    // width: 20rem;
    text-align: center;
    max-width: 100%;
  }

  h1,
  p {
    color: var(--fg);
  }

  h1 {
    font-size: 4rem;
    font-weight: 400;
    margin-bottom: 0.5rem;

    --fg: #{color(gray, 7)};

    @include tm-dark {
      --fg: #{color(gray, 4)};
    }
  }

  p {
    margin-top: 1.5rem;
    // font-style: italic;

    --fg: #{color(gray, 8)};

    @include tm-dark {
      --fg: #{color(gray, 5)};
    }
  }
</style>
