<script context="module" lang="ts">
  export async function load({ stuff, params }) {
    const { api, nvinfo } = stuff

    const nvseed = await api.nvseed(nvinfo.id, params.sname)
    return nvseed.error ? nvseed : { props: { nvinfo }, stuff: { nvseed } }
  }
</script>

<script lang="ts">
  export let nvinfo: CV.Nvinfo
</script>

<svelte:head>
  <title>Chương tiết - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>
<slot />
