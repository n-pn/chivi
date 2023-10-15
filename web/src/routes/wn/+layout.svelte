<script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  $: $crumbs = [{ text: 'Thư viện truyện chữ', href: `/wn` }]
</script>

<slot />
