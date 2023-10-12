<script lang="ts">
  import { page } from '$app/stores'
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  // import type { LayoutData } from './$types'
  // export let data: LayoutData

  $: $crumbs = [{ text: 'Hướng dẫn' }]

  $: title = $page.data.title || 'Hướng dẫn'
  $: mdesc = $page.data.mdesc || 'Hướng dẫn sử dụng'
  $: image = $page.data.image || '/imgs/avatar.png'
</script>

<svelte:head>
  <title>{title} - Chivi</title>
  <meta name="description" content={mdesc} />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={mdesc} />
  <meta property="og:image" content="https://chivi.app{image}" />
</svelte:head>

<slot />
