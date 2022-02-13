<script context="module" lang="ts">
  import { appbar } from '$lib/stores'
  export async function load() {
    appbar.set({ left: [['Thêm truyện', 'file-plus', '/books/+new']] })
    return {}
  }
</script>

<script lang="ts">
  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'
</script>

<NvinfoForm params={new Params()} />
