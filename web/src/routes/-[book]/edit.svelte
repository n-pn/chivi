<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { appbar } from '$lib/stores'
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
