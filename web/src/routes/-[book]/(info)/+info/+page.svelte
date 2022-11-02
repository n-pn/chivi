<script lang="ts">
  import { goto } from '$app/navigation'
  // import { page } from '$app/stores'
  import { session } from '$lib/stores'
  import { Crumb, SIcon } from '$gui'
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo } = data)
  $: nv_href = `/-${nvinfo.bslug}`

  async function delete_book() {
    const bslug = nvinfo.bslug.substring(0, 8)
    await fetch(`api/books/${bslug}/delete`, { method: 'DELETE' })
    await goto('/')
  }
</script>

<Crumb
  tree={[
    [nvinfo.btitle_vi, nv_href],
    ['Sửa thông tin', '.'],
  ]} />

<NvinfoForm {nvinfo}>
  <h1 slot="header">Sửa thông tin truyện [{nvinfo.btitle_vi}]</h1>
</NvinfoForm>

{#if $session.privi > 3}
  <footer>
    <button class="m-btn _harmful _lg" type="button" on:click={delete_book}>
      <SIcon name="trash" />
      <span class="-txt">Xoá bộ sách</span>
    </button>
  </footer>
{/if}

<style lang="scss">
  footer {
    margin-top: var(--gutter);
    @include flex-ca;
  }
</style>
