<script lang="ts">
  import { goto } from '$app/navigation'

  import VicritForm from '$gui/parts/vicrit/VicritForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const on_success = (_: CV.Vicrit) => goto(`/-${data.nvinfo.bslug}/crits`)
</script>

<VicritForm nvinfo={data.nvinfo} form={data.form} {on_success} />
