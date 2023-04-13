<script lang="ts">
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<NvinfoForm nvinfo={data.nvinfo} wnform={data.wnform}>
  <h1 slot="header">Thêm truyện mới</h1>
</NvinfoForm>
