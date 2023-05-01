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
