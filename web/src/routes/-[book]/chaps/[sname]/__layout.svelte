<script context="module" lang="ts">
  export async function load({ stuff, params }) {
    const { api, nvinfo } = stuff

    const nvseed = await api.nvseed(nvinfo.bslug, params.sname)
    return nvseed.error ? nvseed : { stuff: { nvseed } }
  }
</script>

<slot />
