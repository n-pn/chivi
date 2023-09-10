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
    <p><strong>{$page.error.message}</strong></p>

    {#if $page.status == 403}
      <Notext bind:data />
    {:else if $page.status == 404}
      <p>{$page.error.message || 'Đường dẫn không tồn tại!'}</p>
    {:else if $page.status == 455}
      <p>Chưa tồn tại kết quả phân tích ngữ pháp</p>
      <p>
        Nếu bạn có quyền hạn lớn hơn 1, hãy thử bật chế độ tự động phân tích cây
        ngữ pháp trong phần cài đặt.
      </p>
      <p><strong>Lưu ý: Tính năng này về sau sẽ tính phí!</strong></p>
    {:else}
      <p>{$page.error.message}</p>
    {/if}
  </article>
</section>
