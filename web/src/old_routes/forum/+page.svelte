<script lang="ts">
  throw new Error("@migration task: Add data prop (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292707)");

  import CvpostList from '$gui/parts/cvpost/CvpostList.svelte'
  export let dtlist: CV.Dtlist
  const dboard = { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }
</script>

<svelte:head>
  <title>Diễn đàn - Chivi</title>
</svelte:head>

<CvpostList {dtlist} {dboard} _mode={1} />
