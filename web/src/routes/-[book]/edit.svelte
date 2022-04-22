<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ stuff }) {
    return { props: stuff }
  }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'

  import NvinfoForm, { Params } from '$gui/parts/nvinfo/NvinfoForm.svelte'
  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo

  $: topbar.set({
    left: [['Sửa nội dung', 'pencil', { href: '.', show: 'tm' }]],
  })
</script>

<NvinfoForm params={new Params(nvinfo)} />
