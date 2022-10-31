<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import { page } from '$app/stores'

  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'

  export let nvinfo: CV.Nvinfo = $page.stuff.nvinfo
  export let dtlist: CV.Dtlist = { items: [], pgidx: 1, pgmax: 1 }

  $: dboard = { id: nvinfo.id, bname: nvinfo.btitle_vi, bslug: nvinfo.bslug }
</script>

<CvpostList {dboard} {dtlist} />
