<script>
  import Nvinfo from '$sects/Nvinfo.svelte'
  import Appbar from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'
</script>

<Appbar>
  <svelte:fragment slot="left">
    <div class="header-item">
      <span class="header-text">Thêm/sửa sách</span>
    </div>
  </svelte:fragment>
</Appbar>

<Vessel>
  <Nvinfo />
</Vessel>
