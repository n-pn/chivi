<script lang="ts">
  import { goto } from '$app/navigation'

  import VicritForm from '$gui/parts/vicrit/VicritForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const on_success = (_: CV.Vicrit) => goto(`/wn/${data.nvinfo.bslug}/crits`)
</script>

<h3>Đánh giá cá nhân của bạn cho bộ truyện:</h3>

<VicritForm nvinfo={data.nvinfo} form={data.form} {on_success} />

<style lang="scss">
  h3 {
    margin-bottom: 1rem;
  }
</style>
