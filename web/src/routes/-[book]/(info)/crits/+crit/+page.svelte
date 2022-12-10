<script lang="ts">
  import VicritForm from '$gui/parts/vicrit/VicritForm.svelte'
  import { goto } from '$app/navigation'

  import type { PageData } from './$types'
  export let data: PageData
  const on_success = async (_crit) => await goto(`/-${data.nvinfo.bslug}/crits`)
</script>

<VicritForm nvinfo={data.nvinfo} form={data.form} {on_success} />
