<script lang="ts">
  import { goto } from '$app/navigation'
  import { session } from '$lib/stores'
  import { SIcon } from '$gui'
  import NvinfoForm from '$gui/parts/nvinfo/NvinfoForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo_form } = data)

  async function delete_book() {
    await fetch(`api/books/${nvinfo_form.id}/delete`, { method: 'DELETE' })
    await goto('/')
  }
</script>

<NvinfoForm nvinfo={nvinfo_form}>
  <h1 slot="header">Sửa thông tin truyện [{nvinfo_form.btitle_vi}]</h1>
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
