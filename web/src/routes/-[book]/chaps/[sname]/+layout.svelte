<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  export let nvinfo: CV.Nvinfo
</script>

<svelte:head>
  <title>Chương tiết - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>
<slot />
