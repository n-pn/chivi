<script lang="ts">
  import { goto } from '$app/navigation'
  import { session } from '$lib/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import WninfoForm from '$gui/parts/wninfo/WninfoForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ wnform, nvinfo } = data)

  async function delete_book() {
    await fetch(`api/books/${nvinfo.id}/delete`, { method: 'DELETE' })
    await goto('/')
  }
</script>

<WninfoForm {nvinfo} {wnform}>
  <h1 slot="header">Sửa thông tin truyện [{nvinfo.vtitle}]</h1>
</WninfoForm>

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
