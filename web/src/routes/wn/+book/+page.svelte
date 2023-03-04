<script lang="ts">
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'
  import { Crumb } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<Crumb
  tree={[
    ['Thư viện', '/wn'],
    ['Thêm truyện mới', '.'],
  ]} />

<NvinfoForm nvinfo={data.nvinfo} wnform={data.wnform}>
  <h1 slot="header">Thêm truyện mới</h1>
</NvinfoForm>
