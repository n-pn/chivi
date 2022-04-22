<script context="module" lang="ts">
  export async function load() {
    return {}
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'

  $: topbar.set({
    left: [['Thêm truyện', 'file-plus', { href: '/books/+new' }]],
  })
</script>

<NvinfoForm params={new Params()} />
