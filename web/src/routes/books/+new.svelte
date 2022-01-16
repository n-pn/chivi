<script context="module">
  import { data as appbar } from '$sects/Appbar.svelte'

  export async function load() {
    appbar.set({ left: [['Thêm truyện', 'file-plus', '/books/+new']] })
    return {}
  }
</script>

<script>
  import NvinfoForm from '$sects/Nvinfo/Form.svelte'
  import Vessel from '$sects/Vessel.svelte'
</script>

<Vessel>
  <NvinfoForm />
</Vessel>
