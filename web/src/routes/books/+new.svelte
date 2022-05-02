<script lang="ts">
  import { topbar } from '$lib/stores'
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'

  import { Crumb } from '$gui'

  $: topbar.set({
    left: [
      ['Thư viện', 'books', { href: '/books' }],
      ['Thêm truyện mới', 'file-plus', { href: '/books/+new' }],
    ],
  })
</script>

<Crumb
  tree={[
    ['Thư viện', '/books'],
    ['Thêm truyện mới', '.'],
  ]} />

<NvinfoForm>
  <h1 slot="header">Thêm truyện mới</h1>
</NvinfoForm>
