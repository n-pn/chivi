<script lang="ts">
  import WninfoForm from '$gui/parts/wninfo/WninfoForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<WninfoForm nvinfo={data.nvinfo} wnform={data.wnform}>
  <h1 slot="header">Thêm truyện mới</h1>
</WninfoForm>
