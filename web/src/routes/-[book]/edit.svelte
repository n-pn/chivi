<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { data as appbar } from '$gui/sects/Appbar.svelte'

  export async function load({ stuff }) {
    appbar.set({ left: [['Sửa nội dung']] })
    return { props: stuff }
  }
</script>

<script lang="ts">
  import NvinfoForm from '$gui/sects/Nvinfo/Form.svelte'

  export let nvinfo = $page.stuff.nvinfo || {}

  $: params = {
    author: nvinfo.author,
    btitle: nvinfo.zname,
    bcover: nvinfo.bcover,
    status: 0,
  }
</script>

<NvinfoForm {params} />
