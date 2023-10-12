<script lang="ts">
  import { page } from '$app/stores'
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { crumbs } from '$gui/global/Bcrumb.svelte'

  $: $crumbs = [{ text: 'Thư viện truyện chữ', href: `/wn` }]
</script>

<slot />
