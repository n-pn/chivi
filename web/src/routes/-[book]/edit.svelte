<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { appbar } from '$lib/stores'
  export async function load({ stuff }) {
    appbar.set({ left: [['Sửa nội dung']] })
    return { props: stuff }
  }
</script>

<script lang="ts">
  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
</script>

<NvinfoForm params={new Params(nvinfo)} />
