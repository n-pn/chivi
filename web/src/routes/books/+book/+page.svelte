<script context="module">
  export function load() {
    const topbar = {
      left: [
        ['Thư viện', 'books', { href: '/books' }],
        ['Thêm truyện mới', 'file-plus', { href: '/books/+new' }],
      ],
    }
    return { stuff: { topbar } }
  }
</script>

<script lang="ts">
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'
  import { Crumb } from '$gui'
</script>

<Crumb
  tree={[
    ['Thư viện', '/books'],
    ['Thêm truyện mới', '.'],
  ]} />

<NvinfoForm>
  <h1 slot="header">Thêm truyện mới</h1>
</NvinfoForm>
