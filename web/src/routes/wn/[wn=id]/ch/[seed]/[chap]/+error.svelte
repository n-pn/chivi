<script lang="ts">
  import { page } from '$app/stores'
  import type { LayoutData } from './$types'

  import Notext from './Notext.svelte'

  export let data: LayoutData
</script>

<svelte:head>
  <title>{$page.status} - Chivi</title>
</svelte:head>

<section class="wrapper">
  <article class="content">
    <h1>{$page.status}</h1>

    {#if $page.status == 403}
      <Notext bind:data />
    {:else if $page.status == 404}
      <p>{$page.error.message || 'Đường dẫn không tồn tại!'}</p>
    {:else}
      <p>{$page.error.message}</p>
    {/if}
  </article>
</section>
