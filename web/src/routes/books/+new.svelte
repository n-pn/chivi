<script>
  import NvinfoForm from '$sects/Nvinfo/Form.svelte'
  import { data as appbar } from '$sects/Appbar.svelte'
  import Vessel from '$sects/Vessel.svelte'

  $: appbar.set({
    left: [['Thêm truyện', 'file-plus', '/books/+new']],
  })
</script>

<Vessel>
  <NvinfoForm />
</Vessel>
