<script lang="ts">
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'
  import { Crumb } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ wnform, nvinfo } = data)
</script>

<Crumb
  tree={[
    ['Thư viện', '/books'],
    ['Thêm truyện mới', '.'],
  ]} />

<NvinfoForm {nvinfo} {wnform}>
  <h1 slot="header">Thêm truyện mới</h1>
</NvinfoForm>
