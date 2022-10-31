<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'

  export let dboard: CV.Dboard
  export let dtlist: CV.Dtlist
</script>

<svelte:head>
  <title>{dboard.bname} - Diễn đàn - Chivi</title>
</svelte:head>

<CvpostList {dboard} {dtlist} />
